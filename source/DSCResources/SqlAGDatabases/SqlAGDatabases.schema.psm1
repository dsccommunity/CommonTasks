configuration SqlAGDatabases {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]$Values
    )

    <#
    AvailabilityGroupName = [string]
    BackupPath = [string]
    DatabaseName = [string[]]
    InstanceName = [string]
    ServerName = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [Force = [bool]]
    [MatchDatabaseOwner = [bool]]
    [ProcessOnlyOnActiveNode = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
    [ReplaceExisting = [bool]]
    #>

    Import-DscResource -ModuleName SqlServerDsc

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if (-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.DatabaseName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlAGDatabase -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
