Configuration FirewallProfiles {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Profile

    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($value in $Profile) {
        $executionName = ($value.Name + '\' + $value.ValueName) -replace ' ', ''
        (Get-DscSplattedResource -ResourceName FirewallProfile -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
  
}

