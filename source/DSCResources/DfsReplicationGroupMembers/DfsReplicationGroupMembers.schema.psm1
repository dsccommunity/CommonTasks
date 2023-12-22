configuration DfsReplicationGroupMembers {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    <#
    ComputerName = [string]
    GroupName = [string]
    [DependsOn = [string[]]]
    [Description = [string]]
    [DomainName = [string]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    #>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DFSDsc

    foreach ($item in $items)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = "$($item.ComputerName)__$($item.GroupName)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName DFSReplicationGroupMember -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
