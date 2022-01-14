configuration AddsServicePrincipalNames
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $ServicePrincipalNames
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc


    foreach ($spn in $ServicePrincipalNames)
    {
        (Get-DscSplattedResource -ResourceName ADServicePrincipalName -ExecutionName "spn-$((New-Guid).Guid)" -Properties $spn -NoInvoke).Invoke($spn)
    }
}
