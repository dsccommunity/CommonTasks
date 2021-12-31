configuration SharePointCacheAccounts
{
    param (
        [Parameter()]
        [hashtable[]]
        $CacheAccounts
    )

    <#
    SuperReaderAlias = [string]
    SuperUserAlias = [string]
    WebAppUrl = [string]
    [DependsOn = [string[]]]
    [InstallAccount = [PSCredential]]
    [PsDscRunAsCredential = [PSCredential]]
    [SetWebAppPolicy = [bool]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $CacheAccounts)
    {
        $executionName = "$($item.SuperUserAlias)-$($item.SuperUserAlias)"
        (Get-DscSplattedResource -ResourceName SPCacheAccounts -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
