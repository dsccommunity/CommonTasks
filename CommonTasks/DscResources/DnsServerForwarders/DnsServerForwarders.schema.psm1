configuration DnsServerForwarders
{
    param
    (
        [Parameter(Mandatory)]
        [String[]]
        $IPAddresses,

        [Parameter()]
        [Boolean]
        $UseRootHint
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    WindowsFeature DNSServer
    {
        Name   = 'DNS'
        Ensure = 'Present'
    }

    DnsServerForwarder dnsServerForwarderx
    {
        DependsOn        = '[WindowsFeature]DNSServer'
        IsSingleInstance = 'Yes'
        IPAddresses      = $IPAddresses
        UseRootHint      = $UseRootHint
    }
}
