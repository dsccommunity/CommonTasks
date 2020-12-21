configuration NetworkIpConfiguration {
    param (
        [parameter(Mandatory)]
        [hashtable[]] $Interfaces
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    function NetIpInterfaceConfig {
        param(
            [string]   $InterfaceAlias,
            [string]   $IpAddress,
            [int]      $Prefix,
            [string]   $Gateway,
            [string[]] $DnsServer,
            [boolean]  $DisableNetbios,
            [boolean]  $EnableDhcp
        )

        if( $EnableDhcp -eq $true )
        {
            if( -not [string]::IsNullOrWhiteSpace($IpAddress) -or
                -not [string]::IsNullOrWhiteSpace($Gateway) -or 
                ($null -ne $DnsServer -and $DnsServer.Count -gt 0))
            {
                throw "ERROR: Enabled DHCP requires empty 'IpAddress' ($IpAddress), 'Gateway' ($Gateway) and 'DnsServer' ($DnsServer) parameters for interface '$InterfaceAlias'."
            }

            NetIPInterface EnableDhcp {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
                Dhcp           = 'Enabled'
            }

            DnsServerAddress EnableDhcpDNS
            {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
            }
        }
        else 
        {
            if( [string]::IsNullOrWhiteSpace($IpAddress) -or
                [string]::IsNullOrWhiteSpace($Gateway) -or 
                $null -eq $DnsServer -or
                $DnsServer.Count -eq 0)
            {
                throw "ERROR: Interface '$InterfaceAlias' requires none empty 'IpAddress', 'Gateway' and 'DnsServer' parameters."
            }

            NetIPInterface DisableDhcp {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
                Dhcp           = 'Disabled'
            }

            $ip = "$($IpAddress)/$($Prefix)"
            IPAddress NetworkIp {
                IPAddress      = $ip
                AddressFamily  = 'IPv4'
                InterfaceAlias = $InterfaceAlias
            }

            DefaultGatewayAddress DefaultGateway {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $InterfaceAlias
                Address        = $Gateway
            }
            
            DnsServerAddress DnsServers {
                InterfaceAlias = $InterfaceAlias
                AddressFamily  = 'IPv4'
                Address        = $DnsServer
            }

            WinsSetting DisableLmhostsLookup {
                EnableLmHosts    = $true
                IsSingleInstance = 'Yes'
            }
        }

        if ($DisableNetbios) {
            NetBios DisableNetBios {
                InterfaceAlias = $InterfaceAlias
                Setting        = 'Disable'
            }
        }
    }

    foreach( $netIf in $Interfaces )
    {
        if( [string]::IsNullOrWhitespace($netIf.InterfaceAlias) ) {
            $netIf.InterfaceAlias = 'Ethernet'
        }
        if( [string]::IsNullOrWhitespace($netIf.DisableNetbios) ) {
            $netIf.DisableNetbios = $false
        }
        if( [string]::IsNullOrWhitespace($netIf.EnableDhcp) ) {
            $netIf.EnableDhcp = $false
        }

        NetIpInterfaceConfig  -InterfaceAlias $netIf.InterfaceAlias `
                              -IpAddress      $netIf.IpAddress `
                              -Prefix         $netIf.Prefix `
                              -Gateway        $netIf.Gateway `
                              -DnsServer      $netIf.DnsServer `
                              -DisableNetbios $netIf.DisableNetbios `
                              -EnableDhcp     $netIf.EnableDhcp
    }
}
