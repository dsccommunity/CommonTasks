
Configuration ConfigurationManagerDistributionGroups
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteCode,

        [Parameter()]
        [hashtable[]]
        $DistributionGroups
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ConfigMgrCBDsc

    <#
    CMDistributionGroup [String] #ResourceName
    {
        DistributionGroup = [string]
        SiteCode = [string]
        [Collections = [string[]]]
        [CollectionsToExclude = [string[]]]
        [CollectionsToInclude = [string[]]]
        [DependsOn = [string[]]]
        [DistributionPoints = [string[]]]
        [DistributionPointsToExclude = [string[]]]
        [DistributionPointsToInclude = [string[]]]
        [Ensure = [string]{ Absent | Present }]
        [PsDscRunAsCredential = [PSCredential]]
        [SecurityScopes = [string[]]]
        [SecurityScopesToExclude = [string[]]]
        [SecurityScopesToInclude = [string[]]]
    }
    #>

    foreach ($distributionPointGroup in $DistributionGroups)
    {
        $distributionPointGroup = @{} + $distributionPointGroup
        if (-not $distributionPointGroup.Contains('SiteCode'))
        {
            $distributionPointGroup.SiteCode = $SiteCode
        }

        if (-not $distributionPointGroup.Contains('DistributionGroup'))
        {
            throw 'Mandatory property DistributionGroup is missing.'
        }

        (Get-DscSplattedResource -ResourceName CMDistributionGroup -ExecutionName "configmgr_dg_$($distributionPointGroup.SiteCode)_$($distributionPointGroup.DistributionGroup)" -Properties $distributionPointGroup -NoInvoke).Invoke($distributionPointGroup)
    }
}
