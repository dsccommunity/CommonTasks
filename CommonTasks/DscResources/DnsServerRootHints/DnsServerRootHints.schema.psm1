configuration DnsServerRootHints
{
    param
    (
        [hashtable]
        $RootHints
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer
    
    $param = @{
        IsSingleInstance = 'Yes'
        NameServer       = $RootHints
    }

    $executionName = 'RootHints'
    (Get-DscSplattedResource -ResourceName xDnsServerRootHint -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
