Configuration RegistryValues {
    Param(
        [hashtable[]]$Values
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($value in $values) {
        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        $executionName = $value.Key + '\' + $value.ValueName
        (Get-DscSplattedResource -ResourceName Registry -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)

        <#
        Registry r {
            Key = $registryValue.Key
            ValueName = $registryValue.ValueName
            ValueData = $registryValue.ValueData
            ValueType = $registryValue.ValueType
            Ensure = $registryValue.Ensure
        }
        #>
    }
}