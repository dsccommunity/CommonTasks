Configuration FirewallRules {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Rules
    )
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

        
    foreach ($item in $Rules) {
        $executionName = "Firewall_$($item.Name)"
        Write-Host "'$executionName'"
        (Get-DscSplattedResource -ResourceName Firewall -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
    
}

