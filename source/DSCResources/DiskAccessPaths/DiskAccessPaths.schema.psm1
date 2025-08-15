configuration DiskAccessPaths
{
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName StorageDsc

    foreach ($item in $Items)
    {
        $executionName = "DiskAccessPath_$($item.AccessPath)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName DiskAccessPath -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
