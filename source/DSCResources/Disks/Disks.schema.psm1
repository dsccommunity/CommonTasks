configuration Disks
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable[]]
        $Disks
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName StorageDsc

    foreach ($disk in $Disks) {
        # convert string with KB/MB/GB into Uint64
        if ($null -ne $disk.Size) {
            $disk.Size = [Uint64] ($disk.Size / 1)
        }
        
        # convert string with KB/MB/GB into Uint32
        if ($null -ne $disk.AllocationUnitSize) {
            $disk.AllocationUnitSize = [Uint32] ($disk.AllocationUnitSize / 1)
        }

        $executionName = $disk.DiskId
        (Get-DscSplattedResource -ResourceName Disk -ExecutionName $executionName -Properties $disk -NoInvoke).Invoke($disk)
    }
}
