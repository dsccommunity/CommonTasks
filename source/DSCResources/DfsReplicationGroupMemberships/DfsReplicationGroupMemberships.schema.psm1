configuration DfsReplicationGroupMemberships {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    <#
    ComputerName = [string]
    FolderName = [string]
    GroupName = [string]
    [ConflictAndDeletedQuotaInMB = [UInt32]]
    [ContentPath = [string]]
    [DependsOn = [string[]]]
    [DfsnPath = [string]]
    [DomainName = [string]]
    [EnsureEnabled = [string]{ Disabled | Enabled }]
    [MinimumFileStagingSize = [string]{ Size128GB | Size128MB | Size128TB | Size16GB | Size16MB | Size16TB | Size1GB | Size1MB | Size1TB | Size256GB | Size256KB | Size256MB | Size256TB | Size2GB | Size2MB | Size2TB | Size32GB | Size32MB | Size32TB | Size4GB | Size4MB | Size4TB | Size512GB | Size512KB | Size512MB | Size512TB | Size64GB | Size64MB | Size64TB | Size8GB | Size8MB | Size8TB }]
    [PrimaryMember = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
    [ReadOnly = [bool]]
    [RemoveDeletedFiles = [bool]]
    [StagingPath = [string]]
    [StagingPathQuotaInMB = [UInt32]]
    #>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DFSDsc

    foreach ($item in $items)
    {
        if (-not $item.ContainsKey('EnsureEnabled'))
        {
            $item.EnsureEnabled = 'Enabled'
        }

        $executionName = "$($item.ComputerName)__$($item.FolderName)__$($item.GroupName)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName DFSReplicationGroupMembership -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
