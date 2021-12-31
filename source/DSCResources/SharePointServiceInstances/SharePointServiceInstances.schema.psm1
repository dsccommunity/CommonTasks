configuration SharePointServiceInstances
{
    param (
        [Parameter()]
        [hashtable[]]
        $ServiceInstances
    )

    <#
    Name = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [InstallAccount = [PSCredential]]
    [PsDscRunAsCredential = [PSCredential]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ServiceInstances)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name -replace ' ', ''
        (Get-DscSplattedResource -ResourceName SPServiceInstance -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
