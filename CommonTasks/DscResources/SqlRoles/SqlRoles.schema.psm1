configuration SqlRoles {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Roles
    )

    <#
    InstanceName = [string]
    ServerRoleName = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [Members = [string[]]]
    [MembersToExclude = [string[]]]
    [MembersToInclude = [string[]]]
    [PsDscRunAsCredential = [PSCredential]]
    [ServerName = [string]]
    #>
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($role in $Roles)
    {
        if (-not $role.InstanceName)
        {
            $role.InstanceName = $DefaultInstanceName
        }

        if(-not $role.Ensure)
        {
            $role.Ensure = 'Present'
        }

        $executionName = "$($role.InstanceName)_$($role.ServerRoleName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlRole -ExecutionName $executionName -Properties $role -NoInvoke).Invoke($role)
    }
}
