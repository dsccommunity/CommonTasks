configuration RenameNetworkAdapters
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Adapters
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    foreach ($adapter in $Adapters)
    {
        $adapter = @{} + $adapter

        $executionName = "NetAdapterName_$($adapter.NewName)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName NetAdapterName -ExecutionName $executionName -Properties $adapter -NoInvoke).Invoke($adapter)
    }
}
