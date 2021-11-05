configuration SharePointContentDatabases
{
    param(
        [hashtable[]]
        $ContentDatabases
    )

<#
    Name = [string]
    WebAppUrl = [string]
    [DatabaseCredentials = [PSCredential]]
    [DatabaseServer = [string]]
    [DependsOn = [string[]]]
    [Enabled = [bool]]
    [Ensure = [string]{ Absent | Present }]
    [InstallAccount = [PSCredential]]
    [MaximumSiteCount = [UInt16]]
    [PsDscRunAsCredential = [PSCredential]]
    [UseSQLAuthentication = [bool]]
    [WarningSiteCount = [UInt16]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ContentDatabases)
    {
        if (-not $item.ContainsKey('Ensure')) {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name
        (Get-DscSplattedResource -ResourceName SPContentDatabase -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
