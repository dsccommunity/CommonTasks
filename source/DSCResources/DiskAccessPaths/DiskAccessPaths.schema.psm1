configuration DiskAccessPaths
{
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName StorageDsc

    foreach ($item in $Items)
    {
        $executionName = $item.AccessPath
        (Get-DscSplattedResource -ResourceName DiskAccessPath -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
