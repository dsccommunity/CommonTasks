configuration SharePointManagedPaths
{
    param (
        [Parameter()]
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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ManagedPaths)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = Get-Random
        (Get-DscSplattedResource -ResourceName SPManagedPath -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
