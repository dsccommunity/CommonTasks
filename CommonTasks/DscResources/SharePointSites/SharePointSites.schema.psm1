configuration SharePointSites
{
    param(
        [hashtable[]]
        $Sites
    )

<#
    OwnerAlias = [string]
    Url = [string]
    [AdministrationSiteType = [string]{ None | TenantAdministration }]
    [CompatibilityLevel = [UInt32]]
    [ContentDatabase = [string]]
    [CreateDefaultGroups = [bool]]
    [DependsOn = [string[]]]
    [Description = [string]]
    [HostHeaderWebApplication = [string]]
    [InstallAccount = [PSCredential]]
    [Language = [UInt32]]
    [Name = [string]]
    [OwnerEmail = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [QuotaTemplate = [string]]
    [SecondaryEmail = [string]]
    [SecondaryOwnerAlias = [string]]
    [Template = [string]]
#>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $Sites)
    {
        $executionName = $item.Name -replace ' ', ''
        (Get-DscSplattedResource -ResourceName SPSite -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
