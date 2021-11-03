configuration SharePointManagedPaths
{
    param (
        [hashtable[]]
        $ManagedPaths
    )

<#
    Explicit = [bool]
    HostHeader = [bool]
    RelativeUrl = [string]
    WebAppUrl = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [InstallAccount = [PSCredential]]
    [PsDscRunAsCredential = [PSCredential]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ManagedPaths)
    {
        if (-not $item.ContainsKey('Ensure')) {
            $item.Ensure = 'Present'
        }

        $executionName = Get-Random
        (Get-DscSplattedResource -ResourceName SPManagedPath -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
