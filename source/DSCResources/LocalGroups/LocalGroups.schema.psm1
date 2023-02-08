configuration LocalGroups {
    param (
        [Parameter()]
        [hashtable[]]
        $Groups
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($group in $Groups)
    {
        $executionName = $group.GroupName -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xGroup -ExecutionName $executionName -Properties $group -NoInvoke).Invoke($group)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
