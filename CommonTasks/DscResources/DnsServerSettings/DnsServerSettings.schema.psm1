configuration DnsServerSettings
{
    param
    (
        [hashtable]
        $Settings
    )

    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    $executionName = $node.Name
    (Get-DscSplattedResource -ResourceName xDnsServerSetting  -ExecutionName $executionName -Properties $Settings -NoInvoke).Invoke($Settings)
}
