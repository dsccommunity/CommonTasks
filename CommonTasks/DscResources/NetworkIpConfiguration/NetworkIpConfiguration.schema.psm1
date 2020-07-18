configuration NetworkIpConfiguration {
    param (
        [Parameter(Mandatory)]
        [string]$IpAddress,

        [Parameter(Mandatory)]
        [int]$Prefix,

        [Parameter(Mandatory)]
        [string]$Gateway,

        [Parameter(Mandatory)]
        [string[]]$DnsServer,

        [string]$InterfaceAlias = 'Ethernet',

        [switch]$DisableNetbios
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

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

    if ($DisableNetbios) {
        NetBios DisableNetBios {
            InterfaceAlias = $InterfaceAlias
            Setting        = 'Disable'
        }
    }

    WinsSetting DisableLmhostsLookup {
        EnableLmHosts    = $true
        IsSingleInstance = 'Yes'
    }
}
