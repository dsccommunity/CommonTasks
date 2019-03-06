Configuration RegistryValues {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Values
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.5.0.0

    foreach ($value in $values) {
        $executionName = $value.Key + '\' + $value.ValueName
        (Get-DscSplattedResource -ResourceName xRegistry -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}