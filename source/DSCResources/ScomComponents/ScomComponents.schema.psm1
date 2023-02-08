configuration ScomComponents
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Components
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName cScom
    <#
    [-IsSingleInstance] <string> [-Role] <Role> [-SourcePath] <string> [[-ManagementServer] <string>]
    [[-ManagementGroupName] <string>] [[-DataReader] <pscredential>] [[-DataWriter] <pscredential>]
    [[-SqlServerInstance] <string>] [[-SqlInstancePort] <uint16>] [[-DwSqlInstancePort] <uint16>]
    [[-DwSqlServerInstance] <string>] [[-Ensure] <Ensure>] [[-ProductKey] <string>] [[-InstallLocation] <string>]
    [[-ManagementServicePort] <uint16>] [[-ActionAccount] <pscredential>] [[-DASAccount] <pscredential>]
    [[-DatabaseName] <string>] [[-DwDatabaseName] <string>] [[-WebSiteName] <string>] [[-WebConsoleAuthorizationMode] <string>]
    [[-WebConsoleUseSSL] <bool>] [[-UseMicrosoftUpdate] <bool>] [[-SRSInstance] <string>]
    #>

    foreach ($component in $Components)
    {
        $component = @{} + $component
        if (-not $component.Contains('IsSingleInstance')) {$component['IsSingleInstance'] = 'yes'}

        $executionName = "scomcomponent_$($component.Role)"

        (Get-DscSplattedResource -ResourceName ScomComponent -ExecutionName $executionName -Properties $component -NoInvoke).Invoke($component)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
