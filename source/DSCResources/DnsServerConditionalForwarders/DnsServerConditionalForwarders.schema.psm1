configuration DnsServerConditionalForwarders
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $ConditionalForwarders
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    foreach ($conditionalForwarder in $ConditionalForwarders)
    {
        if (-not $conditionalForwarder.ContainsKey('Ensure'))
        {
            $conditionalForwarder.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($conditionalForwarder.Name)"
        (Get-DscSplattedResource -ResourceName DnsServerConditionalForwarder -ExecutionName $executionName -Properties $conditionalForwarder -NoInvoke).Invoke($conditionalForwarder)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
