configuration LocalGroups {
    param (
        [hashtable[]]
        $Groups
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($group in $Groups)
    {
        $executionName = $group.GroupName
        (Get-DscSplattedResource -ResourceName xGroup -ExecutionName $executionName -Properties $group -NoInvoke).Invoke($group)
    }
}
