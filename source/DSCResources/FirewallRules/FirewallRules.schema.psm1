configuration FirewallRules {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Rules
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($item in $Rules)
    {
        $executionName = "Firewall_$($item.Name)"
        (Get-DscSplattedResource -ResourceName Firewall -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
