configuration DiskAccessPaths
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName StorageDsc

    foreach ($item in $Items) {
        $executionName = $item.AccessPath
        (Get-DscSplattedResource -ResourceName DiskAccessPath -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
