configuration SqlRoles {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlRole

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

        $executionName = "$($value.InstanceName)_$($value.ServerRoleName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlRole -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
