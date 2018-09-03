Configuration RegistryValues {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Values
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($value in $values) {
        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        $executionName = $value.Key + '\' + $value.ValueName
        (Get-DscSplattedResource -ResourceName xRegistry -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)

        <#
        xRegistry r {
            Key = $registryValue.Key
            ValueName = $registryValue.ValueName
            ValueData = $registryValue.ValueData
            ValueType = $registryValue.ValueType
            Ensure = $registryValue.Ensure
        }
        #>
    }
}