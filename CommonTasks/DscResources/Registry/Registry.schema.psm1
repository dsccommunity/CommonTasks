Configuration Registry {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$RegistryValues
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($registryValue in $RegistryValues) {
        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        $executionName = $registryValue.Key + '\' + $registryValue.ValueName
        (Get-DscSplattedResource -ResourceName Registry -ExecutionName $executionName -Properties $registryValue -NoInvoke).Invoke($registryValue)

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