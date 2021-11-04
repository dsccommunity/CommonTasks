configuration FirewallRules {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Rules
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc
        
    foreach ($item in $Rules) {
        $executionName = "Firewall_$($item.Name)"
        (Get-DscSplattedResource -ResourceName Firewall -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
    
}
