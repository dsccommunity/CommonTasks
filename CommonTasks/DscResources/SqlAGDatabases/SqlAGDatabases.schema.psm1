configuration SqlAGDatabases {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Databases
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

    foreach ($database in $Databases)
    {
        if (-not $database.InstanceName)
        {
            $database.InstanceName = $DefaultInstanceName
        }

        if(-not $database.Ensure)
        {
            $database.Ensure = 'Present'
        }

        $executionName = "$($database.InstanceName)_$($database.DatabaseName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlAGDatabase -ExecutionName $executionName -Properties $database -NoInvoke).Invoke($database)
    }
}
