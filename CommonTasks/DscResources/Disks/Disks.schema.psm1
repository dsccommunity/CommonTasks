configuration Disks
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable[]]
        $Disks
    )

    Import-DscResource -ModuleName StorageDsc

    foreach ($disk in $Disks) {

        $executionName = $disk.DiskId
        (Get-DscSplattedResource -ResourceName Disk -ExecutionName $executionName -Properties $disk -NoInvoke).Invoke($disk)

    }
}
