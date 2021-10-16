configuration SqlPermissions {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Permissions
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

    foreach ($permission in $Permissions)
    {
        if (-not $permission.InstanceName)
        {
            $permission.InstanceName = $DefaultInstanceName
        }

        if(-not $permission.Ensure)
        {
            $permission.Ensure = 'Present'
        }

        $executionName = "$($permission.InstanceName)_$($permission.Principal -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlPermission -ExecutionName $executionName -Properties $permission -NoInvoke).Invoke($permission)
    }
}
