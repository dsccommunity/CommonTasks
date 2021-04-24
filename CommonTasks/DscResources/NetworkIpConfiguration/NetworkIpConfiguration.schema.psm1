configuration NetworkIpConfiguration {
    param (
        [parameter()]
        [boolean]
        $DisableNetBios = $false,
        
        [parameter()]
        [int16]
        $ConfigureIPv6 = -1,   # < 0 -> no configuration code will be generated
 
        [parameter()]
        [hashtable[]]
        $Interfaces,

        [parameter()]
        [hashtable[]]
        $Routes
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    function NetIpInterfaceConfig
    {
        param(
            [string]   $InterfaceAlias,
            [string]   $IpAddress,
            [int]      $Prefix,
            [string]   $Gateway,
            [string[]] $DnsServer,
            [boolean]  $DisableNetbios,
            [boolean]  $EnableDhcp,
            [boolean]  $EnableLmhostsLookup,
            [boolean]  $DisableIPv6
        )

        if ( $EnableDhcp -eq $true )
        {
            if ( -not [string]::IsNullOrWhiteSpace($IpAddress) -or
                -not [string]::IsNullOrWhiteSpace($Gateway) -or 
                ($null -ne $DnsServer -and $DnsServer.Count -gt 0))
            {
                throw "ERROR: Enabled DHCP requires empty 'IpAddress' ($IpAddress), 'Gateway' ($Gateway) and 'DnsServer' ($DnsServer) parameters for interface '$InterfaceAlias'."
            }

            NetIPInterface "EnableDhcp_$InterfaceAlias" {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
                Dhcp           = 'Enabled'
            }

            DnsServerAddress "EnableDhcpDNS_$InterfaceAlias"
            {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
            }
        }
        else 
        {
            if ( -not [string]::IsNullOrWhiteSpace($IpAddress) )
            {
                # disable DHCP if IP-Address is specified
                NetIPInterface "DisableDhcp_$InterfaceAlias"
                {
                    InterfaceAlias = $InterfaceAlias
                    AddressFamily  = 'IPv4'
                    Dhcp           = 'Disabled'
                }
            
                $ip = "$($IpAddress)/$($Prefix)"

                IPAddress "NetworkIp_$InterfaceAlias" 
                {
                    IPAddress      = $ip
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $InterfaceAlias
                }
            }

            if ( -not [string]::IsNullOrWhiteSpace($Gateway) )
            {
                DefaultGatewayAddress "DefaultGateway_$InterfaceAlias"
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $InterfaceAlias
                    Address        = $Gateway
                }
            }

            if ( $null -ne $DnsServer -and $DnsServer.Count -gt 0 )
            {
                DnsServerAddress "DnsServers_$InterfaceAlias"
                {
                    InterfaceAlias = $InterfaceAlias
                    AddressFamily  = 'IPv4'
                    Address        = $DnsServer
                }
            }
        }
        
        WinsSetting "LmhostsLookup_$InterfaceAlias"
        {
            EnableLmHosts    = $EnableLmhostsLookup
            IsSingleInstance = 'Yes'
        }

        if ($DisableNetbios)
        {
            NetBios "DisableNetBios_$InterfaceAlias"
            {
                InterfaceAlias = $InterfaceAlias
                Setting        = 'Disable'
            }
        }

        if ($DisableIPv6)
        {
            NetAdapterBinding "DisableIPv6_$InterfaceAlias"
            {
                InterfaceAlias = $InterfaceAlias
                ComponentId    = 'ms_tcpip6'
                State          = 'Disabled'
            }
        }
    }

    if ($DisableNetbios -eq $true)
    {
        NetBios DisableNetBios_System
        {
            InterfaceAlias = '*'
            Setting        = 'Disable'
        }
    }

    if ($ConfigureIPv6 -ge 0)
    {
        # see https://docs.microsoft.com/en-US/troubleshoot/windows-server/networking/configure-ipv6-in-windows

        if( $ConfigureIPv6 -gt 255 )
        {
            throw "ERROR: Invalid IPv6 configuration value $ConfigureIPv6 (expected value: 0-255)."
        }

        $configIPv6KeyName = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
        $configIPv6VarName = 'DisabledComponents'

        Script ConfigureIPv6_System
        {
            TestScript = {
                $val = Get-ItemProperty -Path $using:configIPv6KeyName -Name $using:configIPv6VarName -ErrorAction SilentlyContinue

                Write-Verbose "Current IPv6 Configuration value: '$($val.$using:configIPv6VarName)' - expected value: '$using:ConfigureIPv6'"

                if ($null -ne $val -and $val.$using:configIPv6VarName -eq $using:ConfigureIPv6)
                {
                    return $true
                }
                Write-Verbose 'Values are different'
                return $false
            }
            SetScript = {      
                if( -not (Test-Path -Path $using:configIPv6KeyName) ) {
                    New-Item -Path $using:configIPv6KeyName -Force
                }
                Set-ItemProperty -Path $using:configIPv6KeyName -Name $using:configIPv6VarName -Value $using:ConfigureIPv6 -Type DWord
                $global:DSCMachineStatus = 1
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if  ($null -ne $Interfaces)
    {
        foreach ( $netIf in $Interfaces )
        {
            # Remove case sensitivity of ordered Dictionary or Hashtables
            $netIf = @{} + $netIf
                        
            if ( [string]::IsNullOrWhitespace($netIf.InterfaceAlias) )
            {
                $netIf.InterfaceAlias = 'Ethernet'
            }
            if ( $DisableNetbios -eq $true -or [string]::IsNullOrWhitespace($netIf.DisableNetbios) )
            {
                $netIf.DisableNetbios = $false
            }
            if ( [string]::IsNullOrWhitespace($netIf.EnableLmhostsLookup) )
            {
                $netIf.EnableLmhostsLookup = $false
            }
            if ( [string]::IsNullOrWhitespace($netIf.EnableDhcp) )
            {
                $netIf.EnableDhcp = $false
            }
            if ( $DisableIPv6 -eq $true -or [string]::IsNullOrWhitespace($netIf.DisableIPv6) )
            {
                $netIf.DisableIPv6 = $false
            }
            if ( $netIf.EnableDhcp -eq $true -and [string]::IsNullOrWhitespace($netIf.Prefix) )
            {
                $netIf.Prefix = 24
            }

            NetIpInterfaceConfig -InterfaceAlias $netIf.InterfaceAlias `
                -IpAddress $netIf.IpAddress `
                -Prefix $netIf.Prefix `
                -Gateway $netIf.Gateway `
                -DnsServer $netIf.DnsServer `
                -DisableNetbios $netIf.DisableNetbios `
                -EnableLmhostsLookup $netIf.EnableLmhostsLookup `
                -EnableDhcp $netIf.EnableDhcp `
                -DisableIPv6 $netIf.DisableIPv6
        }
    }

    if  ($null -ne $Routes)
    {
        foreach ( $netRoute in $Routes )
        {
            # Remove case sensitivity of ordered Dictionary or Hashtables
            $netRoute = @{} + $netRoute

            if ( [string]::IsNullOrWhitespace($netRoute.InterfaceAlias) )
            {
                $netRoute.InterfaceAlias = 'Ethernet'
            }

            if ( [string]::IsNullOrWhitespace($netRoute.AddressFamily) )
            {
                $netRoute.AddressFamily  = 'IPv4'
            }

            if ( [string]::IsNullOrWhitespace($netRoute.Ensure) )
            {
                $netRoute.Ensure  = 'Present'
            }

            $executionName = "route_$($netRoute.InterfaceAlias)_$($netRoute.AddressFamily)_$($netRoute.DestinationPrefix)_$($netRoute.NextHop)" -replace '[().:\s]', ''
            (Get-DscSplattedResource -ResourceName Route -ExecutionName $executionName -Properties $netRoute -NoInvoke).Invoke($netRoute)    
        }
    }
}
