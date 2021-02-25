configuration DnsServerForwarder
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
    Import-DscResource -ModuleName xDnsServer

    WindowsFeature DNSServer
    {
        Name   = 'DNS'
        Ensure = 'Present'
    }

    xDnsServerForwarder dnsServerForwarder 
    {
        DependsOn        = '[WindowsFeature]DNSServer'
        IsSingleInstance = 'Yes'
        IPAddresses      = $IPAddresses
        UseRootHint      = $UseRootHint
    }
}
