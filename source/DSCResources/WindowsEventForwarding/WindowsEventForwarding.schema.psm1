configuration WindowsEventForwarding
{
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet( 'Collector', 'Source', 'Default')]
        [string]
        $NodeType,

        [Parameter()]
        [boolean]
        $CheckPrerequisites = $false,

        [Parameter()]
        [boolean]
        $FixWsManUrlAcl = $false,

        [Parameter()]
        [string]
        $CollectorName,

        [Parameter()]
        [hashtable[]]
        $Subscriptions
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWindowsEventForwarding

    if( $CheckPrerequisites -eq $True )
    {
        Script NetworkServiceInLocalEventLogReadersGroup
        {
            TestScript = 
            {
                [boolean] $result = $false

                # enum DomainRole
                # - Standalone_Workstation    = 0
                # - Member_Workstation        = 1
                # - Standalone_Server         = 2
                # - Member_Server_            = 3
                # - Backup_Domain_Controller  = 4
                # - Primary_Domain_Controller = 5       
                $domainRole = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole

                if( $domainRole -ne 4 -and $domainRole -ne 5 )
                {
                    # check local member
                    if( $null -ne (Get-LocalGroupMember -Group 'Event Log Readers' -Member 'NT AUTHORITY\NETWORK SERVICE' -ErrorAction SilentlyContinue) )
                    {
                        $result = $true
                    }

                    Write-Verbose "Is 'NT AUTHORITY\NETWORK SERVICE' member of local group 'Event Log Readers': $result"
                }
                else
                {
                    # check domain member
                    if( $null -ne (Get-ADGroupMember -Identity 'Event Log Readers' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'NETWORK SERVICE' }) )
                    {
                        $result = $true
                    }
                    else
                    {
                        Write-Warning "ATTENTION: Adding builtin account 'NT AUTHORITY\NETWORK SERVICE' to domain group 'Event Log Readers' via Powershell is not supported and shall be done manually with RSAT or automatically with a GPO."
                    }

                    Write-Verbose "Is 'NETWORK SERVICE' member of domain group 'Event Log Readers': $result"
                }

                return $result
            }
            SetScript = 
            {
                $domainRole = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole

                if( $domainRole -ne 4 -and $domainRole -ne 5 )
                {
                    # add local member
                    Write-Verbose "Adding builtin account 'NT AUTHORITY\NETWORK SERVICE' to local group 'Event Log Readers'..."
                    Add-LocalGroupMember -Group 'Event Log Readers' -Member 'NT AUTHORITY\NETWORK SERVICE'
                }
                else
                {
                    # add domain member
                    Write-Error "ATTENTION: Adding builtin account 'NT AUTHORITY\NETWORK SERVICE' to domain group 'Event Log Readers' via Powershell is not supported and shall be done manually with RSAT or automatically with a GPO."
                }
            }
            GetScript = { return 'NA' }   
        }
    }

    if ( $NodeType -eq 'Collector' )
    {
        if ($null -eq $Subscriptions -or $Subscriptions.Count -lt 1)
        {
            throw 'ERROR: A Collector node requires at least one subscription definition.'
        }

        if ($FixWsManUrlAcl -eq $true)
        {
            # see KB4494462: Events are not forwarded if the collector is running Windows Server
            # https://docs.microsoft.com/en-us/troubleshoot/windows-server/admin-development/events-not-forwarded-by-windows-server-collector
            [string]$httpUrl = 'http://+:5985/wsman/'
            [string]$httpsUrl = 'https://+:5986/wsman/'
            [string]$newUrlAcl = 'D:(A;;GX;;;S-1-5-80-569256582-2953403351-2909559716-1301513147-412116970)(A;;GX;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)'

            Script SetupWsManUrlAcl
            {
                TestScript =
                {
                    [string]$http = netsh http show urlacl url=$using:httpUrl

                    if (($http -match '\s*SDDL:\s*(?<sddl>.*)$') -eq $false -or $matches.sddl.Trim() -ne $using:newUrlAcl)
                    {
                        Write-Verbose "Fix urlacl of '$using:httpUrl' is required."
                        return $false
                    }

                    [string]$https = netsh http show urlacl url=$using:httpsUrl

                    if (($https -match '\s*SDDL:\s*(?<sddl>.*)$') -eq $false -or $matches.sddl.Trim() -ne $using:newUrlAcl)
                    {
                        Write-Verbose "Fix urlacl of '$using:httpsUrl' is required."
                        return $false
                    }

                    Write-Verbose "Urlacl of '$using:httpUrl' and '$using:httpsUrl'' is valid."
                    return $true
                }
                SetScript  =
                {
                    netsh http delete urlacl url=$using:httpUrl
                    netsh http add urlacl url=$using:httpUrl sddl=$using:newUrlAcl
                    netsh http delete urlacl url=$using:httpsUrl
                    netsh http add urlacl url=$using:httpsUrl sddl=$using:newUrlAcl
                }
                GetScript  = { return 'NA' }
            }
        }

        xWEFCollector wefCollector
        {
            Ensure = 'Present'
            Name   = 'WindowsEventCollector'
        }

        foreach ($subscription in $Subscriptions)
        {
            $subscription.DependsOn = '[xWEFCollector]wefCollector'

            $executionName = "wefsub_$($subscription.SubscriptionID -replace '[().:\s]', '')"
            (Get-DscSplattedResource -ResourceName xWEFSubscription  -ExecutionName $executionName -Properties $subscription -NoInvoke).Invoke($subscription)
        }
    }
    elseif ( $NodeType -eq 'Source' )
    {
        if ($null -ne $Subscriptions -and $Subscriptions.Count -gt 0)
        {
            throw 'ERROR: Subscription definitions are not supported on source nodes.'
        }

        if ([string]::IsNullOrWhiteSpace($CollectorName))
        {
            throw 'ERROR: A CollectorName is required on source nodes.'
        }

        Group CollectorInLocalEventLogReadersGroup
        {
            GroupName        = 'Event Log Readers'
            Ensure           = 'Present'
            MembersToInclude = "$CollectorName"
        }
    }
}
