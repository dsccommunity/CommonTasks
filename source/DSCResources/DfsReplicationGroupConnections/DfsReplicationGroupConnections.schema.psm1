configuration DfsReplicationGroupConnections {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    <#
    DestinationComputerName = [string]
    GroupName = [string]
    SourceComputerName = [string]
    [DependsOn = [string[]]]
    [Description = [string]]
    [DomainName = [string]]
    [Ensure = [string]{ Absent | Present }]
    [EnsureCrossFileRDCEnabled = [string]{ Disabled | Enabled }]
    [EnsureEnabled = [string]{ Disabled | Enabled }]
    [EnsureRDCEnabled = [string]{ Disabled | Enabled }]
    [MinimumRDCFileSizeInKB = [UInt32]]
    [PsDscRunAsCredential = [PSCredential]]
    #>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DFSDsc

    foreach ($item in $items)
    {
        if ($item.DestinationComputerName -eq $item.SourceComputerName)
        {
            Write-Warning "DestinationComputerName '$($item.DestinationComputerName)' and SourceComputerName '$($item.SourceComputerName)' cannot be the same. Skipping configuration item."
            continue
        }

        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = "$($item.GroupName)__$($item.SourceComputerName)__$($item.DestinationComputerName)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName DFSReplicationGroupConnection -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
