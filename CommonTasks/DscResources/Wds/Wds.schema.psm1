configuration Wds
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $RemInstPath,

        [Parameter(Mandatory=$false)]
        [pscredential]
        $RunAsUser,

        [Parameter(Mandatory=$false)]
        [boolean]
        $UseExistingDhcpScope = $false,
        
        [Parameter(Mandatory=$false)]
        [string]
        $ScopeStart,

        [Parameter(Mandatory=$false)]
        [string]
        $ScopeEnd,

        [Parameter(Mandatory=$false)]
        [string]
        $ScopeId,

        [Parameter(Mandatory=$false)]
        [string]
        $SubnetMask,

        [Parameter(Mandatory=$false)]
        [string]
        $DomainName,

        [Parameter(Mandatory=$false)]
        [string]
        $DefaultDeviceOU,

        [Parameter(Mandatory=$false)]
        [hashtable[]]
        $BootImages,

        [Parameter(Mandatory=$false)]
        [hashtable[]]
        $ImageGroups,

        [Parameter(Mandatory=$false)]
        [hashtable[]]
        $InstallImages,

        [Parameter(Mandatory=$false)]
        [hashtable[]]
        $DeviceReservations
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WdsDsc
    Import-DscResource -ModuleName xDhcpServer

    $dependsOnClientScope = ''

    if( $UseExistingDhcpScope -eq $false )
    {
        WindowsFeature dhcpFeature
        {
            Name   = 'DHCP'
            IncludeAllSubFeature = $true
            Ensure = 'Present'
        }

        xDhcpServerScope clientScope
        {
            ScopeId      = $ScopeId
            IPStartRange = $ScopeStart
            IPEndRange   = $ScopeEnd
            SubnetMask   = $SubnetMask
            Name         = 'WdsClients'
            Ensure       = 'Present'
            DependsOn    = '[WindowsFeature]dhcpFeature'
        }

        $dependsOnClientScope = '[xDhcpServerScope]clientScope'
    }
    else
    {
        if( -not [string]::IsNullOrWhiteSpace($ScopeStart) -or
            -not [string]::IsNullOrWhiteSpace($ScopeEnd) -or
            -not [string]::IsNullOrWhiteSpace($SubnetMask) )
        {
            throw "ERROR: if 'UseExistingDhcpScope' is set to 'true' the DHCP scope definition shall be empty."
        }
    }

    WindowsFeature wdsFeature
    {
        Name                 = 'WDS'
        IncludeAllSubFeature = $true
        Ensure               = 'Present'
    }

    if( $null -ne $RunAsUser )
    {
        # the RunAs user requires local administrator rights
        Group addRunAsUserToLocalAdminsGroup
        {
            GroupName        = 'Administrators'
            Ensure           = 'Present'
            MembersToInclude = $RunAsUser.UserName
        }        
    }

    WdsInitialize wdsInit
    {
        IsSingleInstance     = 'Yes'
        PsDscRunAsCredential = $RunAsUser
        Path                 = $RemInstPath
        Authorized           = $true
        Standalone           = $false
        Ensure               = 'Present'
        DependsOn            = '[WindowsFeature]wdsFeature'
    }

    Service wdsService
    {
        Name        = 'WDSServer'
        StartupType = 'Automatic'
        State       = 'Running'
        Ensure      = 'Present'
        DependsOn   = '[WdsInitialize]wdsInit'
    }

    $dependsOnWdsService = '[Service]wdsService'

    if( $null -ne $BootImages )
    {
        foreach( $image in $BootImages )
        {
            $image.DependsOn = $dependsOnWdsService

            $executionName = "bootImg_$($image.NewImageName -replace '[().:\s]', '')"

            (Get-DscSplattedResource -ResourceName WdsBootImage -ExecutionName $executionName -Properties $image -NoInvoke).Invoke($image)
        }
    }

    if( $null -ne $ImageGroups )
    {
        foreach( $group in $ImageGroups )
        {
            Script "imgGroup_$($group.Name -replace '[().:\s]', '_')"
            {
                TestScript = {
                    $wdsGroup = Get-WdsInstallImageGroup -Name $using:group.Name -ErrorAction SilentlyContinue
    
                    if( $using:group.Ensure -eq 'Absent' )
                    {
                        if( $null -eq $wdsGroup -or $wdsGroup.Count -eq 0 )
                        {
                            return $true
                        }
                    }
                    else
                    {
                        if( $null -ne $wdsGroup -and $wdsGroup.Name -eq $using:group.Name )
                        {
                            if( [string]::IsNullOrWhiteSpace($using:group.SecurityDescriptor) -or
                                $wdsGroup.Security -eq $using:group.SecurityDescriptor)
                            {
                                return $true                            
                            }
                        }
                    }
                    return $false
                }
                SetScript = {
                    $params = @{
                        Name = $group.Name
                    }

                    if( $using:group.Ensure -eq 'Absent' )
                    {
                        Remove-WdsInstallImageGroup @params
                    }
                    else 
                    {
                        if( -not [string]::IsNullOrWhiteSpace($using:group.SecurityDescriptor) )
                        {
                            $params.SecurityDescriptorSDDL = $using:group.SecurityDescriptor   
                        }

                        $wdsGroup = Get-WdsInstallImageGroup -Name $using:group.Name -ErrorAction SilentlyContinue

                        if( $null -eq $wdsGroup )
                        {
                            New-WdsInstallImageGroup @params                            
                        }
                        else
                        {
                            Set-WdsInstallImageGroup @params                            
                        }
                    }
                }
                GetScript = { return @{result = 'N/A'}}
                DependsOn = $dependsOnWdsService
            }        
        }
    }

    if( $null -ne $InstallImages )
    {
        foreach( $image in $InstallImages )
        {
            $image.DependsOn = $dependsOnWdsService

            $executionName = "instImg_$($image.NewImageName -replace '[().:\s]', '')"

            (Get-DscSplattedResource -ResourceName WdsInstallImage -ExecutionName $executionName -Properties $image -NoInvoke).Invoke($image)
        }
    }

    if( $null -ne $DeviceReservations )
    {
        foreach( $devRes in $DeviceReservations )
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $devRes = @{}+$devRes

            if( -not $devRes.ContainsKey('Ensure') )
            {
                $devRes.Ensure = 'Present'
            }

            # make a DHCP reservation
            if( -not [string]::IsNullOrWhiteSpace($devRes.IpAddress) )
            {
                if( [string]::IsNullOrWhiteSpace($ScopeId) )
                {
                    throw "ERROR: if 'IpAddress' is specified the parameter ScopeId is required to make a DHCP reservation."
                }

                xDhcpServerReservation "dhcpRes_$($devRes.DeviceName -replace '[().:\s]', '')"
                {
                    IPAddress        = $devRes.IpAddress
                    ClientMACAddress = $devRes.MacAddress
                    Name             = $devRes.DeviceName
                    ScopeID          = $ScopeId
                    Ensure           = $devRes.Ensure
                    DependsOn        = $dependsOnClientScope
                }                
            }

            # use MacAddress as DeviceID if it's not specified
            if( [string]::IsNullOrWhiteSpace($devRes.DeviceID) )
            {
                $devRes.DeviceID  = $devRes.MacAddress
            }

            # remove DHCP specific attributes
            $devRes.Remove('IpAddress')
            $devRes.Remove('MacAddress')

            $devRes.DependsOn = $dependsOnWdsService

            if( $devRes.JoinDomain -eq $true )
            {
                if( [string]::IsNullOrWhiteSpace($DomainName) )
                {
                    throw "ERROR: $($devRes.DeviceName) - DomainName shall be specified to make a domain join."
                }

                $devRes.Domain = $DomainName

                if( -not [string]::IsNullOrWhiteSpace($DefaultDeviceOU) -and [string]::IsNullOrWhiteSpace($devRes.OU))
                {
                    $devRes.OU = $DefaultDeviceOU
                }
            }
            
            if( [string]::IsNullOrWhiteSpace($devRes.User) )
            {
                # remove JoinRights if no user is specified
                $devRes.Remove( 'JoinRights' )
            }
            else
            {
                if( [string]::IsNullOrWhiteSpace($devRes.JoinRights) )
                {
                    $devRes.JoinRights = 'JoinOnly'
                }
            }

            if( [string]::IsNullOrWhiteSpace($devRes.PxePromptPolicy) )
            {
                $devRes.PxePromptPolicy = 'NoPrompt'
            }

            if( $null -ne $RunAsUser )
            {
                $devRes.PsDscRunAsCredential = $RunAsUser
            }

            $executionName = "wdsRes_$($devRes.DeviceName -replace '[().:\s]', '')"

            (Get-DscSplattedResource -ResourceName WdsDeviceReservation -ExecutionName $executionName -Properties $devRes -NoInvoke).Invoke($devRes)
        }
    }
}
