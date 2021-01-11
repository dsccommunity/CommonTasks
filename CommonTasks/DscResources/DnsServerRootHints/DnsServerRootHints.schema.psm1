configuration DnsServerRootHints
{
    param
    (
        [hashtable]
        $RootHints
    )

    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    
    $param = @{
        IsSingleInstance = 'Yes'
        NameServer       = $RootHints
    }

    $executionName = 'RootHints'
    (Get-DscSplattedResource -ResourceName xDnsServerRootHint -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
