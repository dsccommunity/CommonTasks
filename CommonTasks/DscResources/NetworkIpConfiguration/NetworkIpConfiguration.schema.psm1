Configuration NetworkIpConfiguration {
    Param(
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
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.5.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.0.0.0

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