Configuration FirewallRules {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Rules
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

        
    foreach ($value in $Rules) {
        $executionName = ($value.Name + '\' + $value.ValueName) -replace ' ', ''
        (Get-DscSplattedResource -ResourceName Firewall -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
    
}

