configuration SqlAliases {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
    )

    <#
    Name = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [Protocol = [string]{ NP | TCP }]
    [PsDscRunAsCredential = [PSCredential]]
    [ServerName = [string]]
    [TcpPort = [UInt16]]
    [UseDynamicTcpPort = [bool]]
    #>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAlias

    foreach ($value in $Values)
    {
        if (-not $value.ContainsKey('Ensure'))
        {
            $value.Ensure = 'Present'
        }

        $executionName = $value.Name
        (Get-DscSplattedResource -ResourceName SqlAlias -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
