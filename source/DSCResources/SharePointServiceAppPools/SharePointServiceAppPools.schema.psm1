configuration SharePointServiceAppPools
{
    param(
        [hashtable[]]
        $ServiceAppPools
    )

<#
    Name = [string]
    ServiceAccount = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [InstallAccount = [PSCredential]]
    [PsDscRunAsCredential = [PSCredential]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ServiceAppPools)
    {
        if (-not $item.ContainsKey('Ensure')) {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name -replace ' ', ''
        (Get-DscSplattedResource -ResourceName SPServiceAppPool -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
