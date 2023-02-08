configuration FirewallProfiles {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Profile
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($item in $Profile)
    {
        $executionName = "FirewallProfile_$($item.Name)"
        (Get-DscSplattedResource -ResourceName FirewallProfile -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
