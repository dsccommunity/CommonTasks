configuration SqlDatabases {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Databases
    )

    <#
    InstanceName = [string]
    Name = [string]
    [Collation = [string]]
    [CompatibilityLevel = [string]{ Version100 | Version110 | Version120 | Version130 | Version140 | Version150 | Version80 | Version90 }]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [OwnerName = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [RecoveryModel = [string]{ BulkLogged | Full | Simple }]
    [ServerName = [string]]
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

        $executionName = "$($database.InstanceName)_$($database.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlDatabase -ExecutionName $executionName -Properties $database -NoInvoke).Invoke($database)
    }
}
