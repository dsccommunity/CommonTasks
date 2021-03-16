configuration NetworkIpConfiguration {
    param (
        [parameter()]
        [boolean[]] $DisableNetBios,
        
        [parameter()]
        [boolean[]] $DisableIPv6,

        [parameter()]
        [hashtable[]] $Interfaces
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

    if ($DisableIpv6 -eq $true)
    {
        Script DisableIPv6_System
        {
            TestScript = {
                $result = $true

                $val = Get-NetIPv6Protocol | Select-Object MldLevel, DefaultHopLimit, IcmpRedirects

                Write-Verbose "IPv6Protocol settings: $val"

                if( $val.MldLevel -ne 'None' -or
                    $val.DefaultHopLimit -ne 64 -or
                    $val.IcmpRedirects -ne 'Disabled' )
                {
                    Write-Verbose 'IPv6Protocol parameters have not the expected values.'
                    $result = $false
                }

                $cnt = (Get-NetIPInterface -InterfaceAlias '*' -AddressFamily IPv6 | `
                        Select-Object Dhcp, RouterDiscovery, NlMtu, DadTransmits | `
                        Where-Object { $_.Dhcp -ne 'Disabled' -or $_.RouterDiscovery -ne 'Disabled' -or $_.NlMtu -ne 1280 -or $_.DadTransmits -ne 0 } | `
                        Measure-Object).Count

                Write-Verbose "NetIPInterfaces with unexpected values: $cnt"
 
                return $result
            }
            SetScript = {      
                Set-NetIPv6Protocol -MldLevel none -DefaultHopLimit 64 -IcmpRedirects Disabled
                Set-NetIPInterface -InterfaceAlias '*' -AddressFamily IPv6 -Dhcp Disabled -RouterDiscovery Disabled -NlMtuBytes 1280 -DadTransmits 0
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
}
