Configuration FirewallProfiles {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Profile

    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($item in $Profile) {
        $executionName = "FirewallProfile_$($item.Name)"
        Write-Host "'$executionName'"
        (Get-DscSplattedResource -ResourceName FirewallProfile -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
  
}

