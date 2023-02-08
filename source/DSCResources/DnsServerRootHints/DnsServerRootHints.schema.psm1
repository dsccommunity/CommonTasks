configuration DnsServerRootHints
{
    param
    (
        [Parameter()]
        [hashtable]
        $RootHints
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    $param = @{
        IsSingleInstance = 'Yes'
        NameServer       = $RootHints
    }

    $executionName = 'RootHints'
    (Get-DscSplattedResource -ResourceName DnsServerRootHint -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
