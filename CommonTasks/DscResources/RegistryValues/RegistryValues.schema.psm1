configuration RegistryValues {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Values
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($value in $values) {
        $executionName = ($value.Key + '\' + $value.ValueName) -replace ' ', ''
        (Get-DscSplattedResource -ResourceName xRegistry -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
