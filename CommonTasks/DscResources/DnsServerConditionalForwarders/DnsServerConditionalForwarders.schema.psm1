configuration DnsServerConditionalForwarders
{
    param
    (
        [hashtable[]]
        $ConditionalForwarders
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    foreach ($conditionalForwarder in $ConditionalForwarders) {
        if (-not $conditionalForwarder.ContainsKey('Ensure')) {
            $conditionalForwarder.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($conditionalForwarder.Name)"
        (Get-DscSplattedResource -ResourceName xDnsServerConditionalForwarder -ExecutionName $executionName -Properties $conditionalForwarder -NoInvoke).Invoke($conditionalForwarder)
    }
}
