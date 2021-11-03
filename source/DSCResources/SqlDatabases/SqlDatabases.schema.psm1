configuration SqlDatabases {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Values
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

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if(-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlDatabase -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
