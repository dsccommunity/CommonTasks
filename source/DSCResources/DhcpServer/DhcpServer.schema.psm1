# see https://github.com/dsccommunity/DhcpServerDsc
configuration DhcpServer
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Scopes,

        [Parameter()]
        [object[]]
        $ExclusionRanges,

        [Parameter()]
        [hashtable[]]
        $OptionValues,

        [Parameter()]
        [hashtable[]]
        $Reservations,

        [Parameter()]
        [hashtable]
        $Authorization,

        [Parameter()]
        [bool]
        $EnableSecurityGroups
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DhcpServerDsc

    # install AD tools if AD integration is activated
    if ($null -ne $Authorization -or $EnableSecurityGroups -eq $true)
    {
        WindowsFeature RSATADFeatures
        {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }
    }

    WindowsFeature DHCPServer
    {
        Name      = 'DHCP'
        Ensure    = 'Present'
    }

    if ($EnableSecurityGroups -eq $true)
    {
        Script DHCPSecGroups
        {
            SetScript  = {
                netsh dhcp add securitygroups
                Restart-Service dhcpserver
            }
            TestScript = {
                $adList = Get-ADDomainController -Filter '*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

                if ( $null -ne $adList -and $env:ComputerName -in $adList )
                {
                    $checkDhcpSecGrpA = Get-ADGroup -filter 'Name -eq "DHCP Administrators"' -ErrorAction SilentlyContinue
                    $checkDhcpSecGrpU = Get-ADGroup -filter 'Name -eq "DHCP Users"' -ErrorAction SilentlyContinue
                }
                else
                {
                    $checkDhcpSecGrpA = Get-LocalGroup -Name 'DHCP Administrators' -ErrorAction SilentlyContinue
                    $checkDhcpSecGrpU = Get-LocalGroup -Name 'DHCP Users' -ErrorAction SilentlyContinue
                }

                if ( $null -eq $checkDhcpSecGrpA -or $null -eq $checkDhcpSecGrpU )
                {
                    Write-Verbose -Message 'Missing DHCP Security groups.'
                    return $false
                }

                Write-Verbose -Message 'DHCP Security groups are existing.'
                return $true
            }
            GetScript  = { return `
                @{
                    result = 'N/A'
                }
            }
            DependsOn  = '[WindowsFeature]DHCPServer'
        }
    }

    if ($null -ne $Scopes)
    {
        foreach ($scope in $Scopes.GetEnumerator())
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $scope = @{} + $scope

            if ( [String]::IsNullOrWhitespace($scope.Ensure) )
            {
                $scope.Ensure = 'Present'
            }

            if ( [String]::IsNullOrWhitespace($scope.AddressFamily) )
            {
                $scope.AddressFamily = 'IPv4'
            }

            $scope.DependsOn = '[WindowsFeature]DHCPServer'

            $nameProtection = $scope.DnsNameProtection

            $scope.Remove( 'DnsNameProtection' )

            $executionName = "dhcpscope_$($scope.ScopeID -replace '[-.\s]','_')"
            (Get-DscSplattedResource -ResourceName xDhcpServerScope -ExecutionName $executionName -Properties $scope -NoInvoke).Invoke($scope)

            # generate DNS settings only if scope is present and one of the DNS settings are explicitly specified
            if ($scope.Ensure -eq 'Present' -and $null -ne $nameProtection)
            {
                [string]$scopeId = $scope.ScopeID
                [boolean]$dnsNameProtection = $nameProtection

                Script "$($executionName)_DnsSetting"
                {
                    SetScript  = {
                        Write-Verbose "DHCP Scope: $using:scopeId -> set DNS NameProtection to $using:dnsNameProtection"
                        Set-DhcpServerv4DnsSetting -ScopeId $using:scopeId -NameProtection $using:dnsNameProtection
                    }
                    TestScript = {
                        Write-Verbose "DHCP Scope: $using:scopeId -> test DNS NameProtection: $using:dnsNameProtection"
                        $dnsSetting = Get-DhcpServerv4DnsSetting -ScopeId $using:scopeId
                        Write-Verbose "DNS setting: $(($dnsSetting | Select-Object -Property '*' -ExcludeProperty 'Cim*') -join ', ' | Out-String)"

                        if ( $null -ne $dnsSetting -and $dnsSetting.NameProtection -eq $using:dnsNameProtection )
                        {
                            return $True
                        }

                        return $False
                    }
                    GetScript  = { return `
                        @{
                            result = 'N/A'
                        }
                    }
                    DependsOn  = "[xDhcpServerScope]$executionName"
                }
            }
        }
    }

    if ( $null -ne $ExclusionRanges )
    {
        [int] $i = 0

        foreach ($exclusionRange in $ExclusionRanges.GetEnumerator())
        {
            $exclusionRange.DependsOn = '[WindowsFeature]DHCPServer'

            $i++
            (Get-DscSplattedResource -ResourceName DhcpServerExclusionRange -ExecutionName "dhcpExclusionRange$i" -Properties $exclusionRange -NoInvoke).Invoke($exclusionRange)
        }
    }

    if ($null -ne $Reservations)
    {
        foreach ($reservation in $Reservations.GetEnumerator())
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $reservation = @{} + $reservation

            if ([String]::IsNullOrWhitespace($reservation.Ensure))
            {
                $reservation.Ensure = 'Present'
            }

            if ([String]::IsNullOrWhitespace($reservation.AddressFamily))
            {
                $reservation.AddressFamily = 'IPv4'
            }

            # remove all separators from MAC Address
            $reservation.ClientMACAddress = $reservation.ClientMACAddress -replace '[-:\s]', ''

            $reservation.DependsOn = '[WindowsFeature]DHCPServer'

            $executionName = "dhcpReservation_$($reservation.ScopeID -replace '[().:\s]', '_')__$($reservation.IPAddress -replace '[().:\s]', '_')"

            (Get-DscSplattedResource -ResourceName xDhcpServerReservation -ExecutionName $executionName -Properties $reservation -NoInvoke).Invoke($reservation)
        }
    }

    if ( $null -ne $OptionValues )
    {
        foreach ($optionValue in $OptionValues.GetEnumerator())
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $optionValue = @{} + $optionValue

            $optionValue.DependsOn = '[WindowsFeature]DHCPServer'

            # set VendorClass/UserClass to default if missing or empty
            if ([String]::IsNullOrWhitespace($optionValue.VendorClass))
            {
                $optionValue.VendorClass = ''
            }

            if ([String]::IsNullOrWhitespace($optionValue.UserClass))
            {
                $optionValue.UserClass = ''
            }

            (Get-DscSplattedResource -ResourceName DhcpServerOptionValue -ExecutionName "dhcpServerOptionValue$($optionValue.OptionId)" -Properties $optionValue -NoInvoke).Invoke($optionValue)
        }
    }

    if ($null -ne $Authorization)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $Authorization = @{} + $Authorization

        if ([String]::IsNullOrWhitespace($Authorization.Ensure))
        {
            $Authorization.Ensure = 'Present'
        }

        $Authorization.IsSingleInstance = 'Yes'

        (Get-DscSplattedResource -ResourceName xDhcpServerAuthorization -ExecutionName 'dhcpSrvAuth' -Properties $Authorization -NoInvoke).Invoke($Authorization)
    }
}
