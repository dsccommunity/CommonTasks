configuration DnsServerConditionalForwarders
{
    param
    (
        [hashtable[]]
        $ConditionalForwarders
    )

    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    foreach ($conditionalForwarder in $ConditionalForwarders) {
        if (-not $conditionalForwarder.ContainsKey('Ensure')) {
            $conditionalForwarder.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($conditionalForwarder.Name)"
        (Get-DscSplattedResource -ResourceName xDnsServerConditionalForwarder -ExecutionName $executionName -Properties $conditionalForwarder -NoInvoke).Invoke($conditionalForwarder)
    }
}
