configuration SqlPermissions {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Values
    )

    <#
    InstanceName = [string]
    Principal = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [Permission = [string[]]{ AlterAnyAvailabilityGroup | AlterAnyEndPoint | ConnectSql | ViewServerState }]
    [PsDscRunAsCredential = [PSCredential]]
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

        $executionName = "$($value.InstanceName)_$($value.Principal -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlPermission -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
