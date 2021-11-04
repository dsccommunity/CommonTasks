configuration IpConfiguration
{
    param
    (
        [hashtable[]]
        $Adapter
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($nic in $Adapter)
    {
        $resourceName = "NetAdapter$($nic.NewName)$((New-Guid).Guid)"
        NetAdapterName $resourceName
        {
            MacAddress                     = $nic.MacAddress
            NewName                        = $nic.NewName
            IgnoreMultipleMatchingAdapters = $true
        }

        NetAdapterState "NetAdapterState$($nic.NewName)$((New-Guid).Guid)"
        {
            Name      = $nic.NewName
            State     = 'Enabled'
            DependsOn = "[NetAdapterName]$resourceName"
        }

        if ($nic.Contains('IPAddress') -and -not [string]::IsNullOrWhiteSpace($nic.IPAddress))
        {
            IPAddress "IpAddress$($nic.NewName)$((New-Guid).Guid)"
            {
                InterfaceAlias = $nic.NewName
                IPAddress      = $nic.IPAddress
                AddressFamily  = $nic.AddressFamily
                DependsOn      = "[NetAdapterName]$resourceName"
            }
        }

        if ($nic.Contains('GatewayAddress'))
        {
            DefaultGatewayAddress "Gateway$($nic.NewName)$((New-Guid).Guid)"
            {
                InterfaceAlias = $nic.NewName
                AddressFamily  = $nic.AddressFamily
                Address        = $nic.GatewayAddress
                DependsOn      = "[NetAdapterName]$resourceName"
            }
        }

        if ($nic.Contains('DnsServerAddress'))
        {
            DNSServerAddress "Dns$($nic.NewName)$((New-Guid).Guid)"
            {
                Address        = $nic.DnsServerAddress
                InterfaceAlias = $nic.NewName
                DependsOn      = "[NetAdapterName]$resourceName"
                AddressFamily  = $nic.AddressFamily
            }
        }
    }
}
