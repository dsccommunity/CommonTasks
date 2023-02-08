configuration DnsServerForwarders
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String[]]
        $IPAddresses,

        [Parameter()]
        [Boolean]
        $UseRootHint
    )

    $curPSModulePath = $env:PSModulePath

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

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
