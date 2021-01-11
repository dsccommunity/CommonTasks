configuration Scripts {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($item in $Items) {

        $executionName = "Script_$($item.Name)"
        [void]$item.Remove('Name')
        (Get-DscSplattedResource -ResourceName xScript -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)

    }
}
