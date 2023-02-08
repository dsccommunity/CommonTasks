configuration AddsServicePrincipalNames
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $ServicePrincipalNames
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc


    foreach ($spn in $ServicePrincipalNames)
    {
        (Get-DscSplattedResource -ResourceName ADServicePrincipalName -ExecutionName "spn-$((New-Guid).Guid)" -Properties $spn -NoInvoke).Invoke($spn)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
