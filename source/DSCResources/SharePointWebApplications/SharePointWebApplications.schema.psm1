configuration SharePointWebApplications
{
    param (
        [Parameter()]
        [hashtable[]]
        $WebApplications
    )

    <#
    ApplicationPool = [string]
    ApplicationPoolAccount = [string]
    Name = [string]
    WebAppUrl = [string]
    [AllowAnonymous = [bool]]
    [DatabaseCredentials = [PSCredential]]
    [DatabaseName = [string]]
    [DatabaseServer = [string]]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [HostHeader = [string]]
    [InstallAccount = [PSCredential]]
    [Path = [string]]
    [Port = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [UseClassic = [bool]]
    [UseSQLAuthentication = [bool]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $WebApplications)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name -replace ' ', ''
        (Get-DscSplattedResource -ResourceName SPWebApplication -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
