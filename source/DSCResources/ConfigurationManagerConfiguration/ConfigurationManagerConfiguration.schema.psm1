
Configuration ConfigurationManagerConfiguration
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $SiteCode,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SccmInstallAccount,

        [Parameter()]
        [hashtable[]]
        $CMAccounts,

        [Parameter()]
        [string[]]
        $LocalAdministrators = @('contoso\SCCM-Servers', 'contoso\SCCM-CMInstall', 'contoso\Admin'),

        [Parameter()]
        [hashtable]
        $EmailSettings,

        [Parameter()]
        [hashtable]
        $SystemDiscovery,

        [Parameter()]
        [hashtable]
        $ForestDiscovery,

        [Parameter()]
        [hashtable]
        $NetworkDiscovery,

        [Parameter()]
        [hashtable]
        $HeartbeatDiscovery,

        [Parameter()]
        [hashtable]
        $UserDiscovery,

        [Parameter()]
        [hashtable]
        $ClientStatusSettings,

        [Parameter()]
        [hashtable[]]
        $SiteMaintenanceConfigurations,

        [Parameter()]
        [hashtable[]]
        $BoundaryGroups,

        [Parameter()]
        [hashtable[]]
        $SiteAdmins,

        [Parameter()]
        [hashtable]
        $CollectionSettings,

        [Parameter()]
        [hashtable]
        $StatusReportingSettings,

        [Parameter()]
        [hashtable[]]
        $DistributionPointGroups,

        [Parameter()]
        [hashtable]
        $ManagementPoint,

        [Parameter()]
        [hashtable]
        $SoftwareUpdatePoint,

        [Parameter()]
        [hashtable]
        $SoftwareUpdatePointComponent
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ConfigMgrCBDsc
    Import-DscResource -ModuleName UpdateServicesDsc

    # region ConfigCBMgr configurations
    foreach ($account in $CMAccounts)
    {
        CMAccounts "AddingAccount-$($account.UserName)"
        {
            SiteCode             = $SiteCode
            Account              = $account.UserName
            AccountPassword      = $account.Password
            Ensure               = 'Present'
            PsDscRunAsCredential = $SccmInstallAccount
        }
    }

    if ($EmailSettings)
    {
        $EmailSettings['SiteCode'] = $SiteCode
        $EmailSettings['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMEmailNotificationComponent -ExecutionName "CmMailSettings$($SiteCode)" -Properties $EmailSettings -NoInvoke).Invoke($EmailSettings)
    }

    if ($ForestDiscovery)
    {
        $ForestDiscovery['SiteCode'] = $SiteCode
        $ForestDiscovery['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMForestDiscovery -ExecutionName "CMForestDiscovery$($SiteCode)" -Properties $ForestDiscovery -NoInvoke).Invoke($ForestDiscovery)
    }

    if ($SystemDiscovery)
    {
        $SystemDiscovery['SiteCode'] = $SiteCode
        $SystemDiscovery['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMSystemDiscovery -ExecutionName "CMSystemDiscovery$($SiteCode)" -Properties $SystemDiscovery -NoInvoke).Invoke($SystemDiscovery)
    }

    if ($NetworkDiscovery)
    {
        $NetworkDiscovery['SiteCode'] = $SiteCode
        $NetworkDiscovery['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMNetworkDiscovery -ExecutionName "CMNetworkDiscovery$($SiteCode)" -Properties $NetworkDiscovery -NoInvoke).Invoke($NetworkDiscovery)
    }

    if ($HeartbeatDiscovery)
    {
        $HeartbeatDiscovery['SiteCode'] = $SiteCode
        $HeartbeatDiscovery['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMHeartbeatDiscovery -ExecutionName "CMHeartbeatDiscovery$($SiteCode)" -Properties $HeartbeatDiscovery -NoInvoke).Invoke($HeartbeatDiscovery)
    }

    if ($UserDiscovery)
    {
        $UserDiscovery['SiteCode'] = $SiteCode
        $UserDiscovery['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMUserDiscovery -ExecutionName "CMUserDiscovery$($SiteCode)" -Properties $UserDiscovery -NoInvoke).Invoke($UserDiscovery)
    }

    if ($ClientStatusSettings)
    {
        $ClientStatusSettings['SiteCode'] = $SiteCode
        $ClientStatusSettings['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMClientStatusSettings -ExecutionName "CMClientStatusSettings$($SiteCode)" -Properties $ClientStatusSettings -NoInvoke).Invoke($ClientStatusSettings)
    }

    foreach ($maintenance in $SiteMaintenanceConfigurations)
    {
        $maintenance['SiteCode'] = $SiteCode
        $maintenance['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMSiteMaintenance -ExecutionName "CMSiteMaintenance$($maintenance.TaskName -replace '\W')" -Properties $maintenance -NoInvoke).Invoke($maintenance)
    }

    foreach ($bg in $BoundaryGroups)
    {
        $boundaryDependencies = @()
        foreach ($boundary in $bg.Boundaries)
        {
            $boundary['SiteCode'] = $SiteCode
            $boundary['PsDscRunAsCredential'] = $SccmInstallAccount
            (Get-DscSplattedResource -ResourceName CMBoundaries -ExecutionName "CMBoundary$($boundary.DisplayName -replace '\W')" -Properties $boundary -NoInvoke).Invoke($boundary)
            $boundaryDependencies += "[CMBoundaries]CMBoundary$($boundary.DisplayName -replace '\W')"
        }

        $bg['SiteCode'] = $SiteCode
        $bg['PsDscRunAsCredential'] = $SccmInstallAccount
        $bg['DependsOn'] = $boundaryDependencies

        $bg.Boundaries = foreach ($bound in $bg.Boundaries)
        {
            DSC_CMBoundaryGroupsBoundaries
            {
                Value = $bound.Value
                Type  = $bound.Type
            }
        }
        (Get-DscSplattedResource -ResourceName CMBoundaryGroups -ExecutionName "BoundaryGroup$($bg.BoundaryGroup -replace '\W')" -Properties $bg -NoInvoke).Invoke($bg)
    }

    foreach ($admin in $SiteAdmins)
    {
        $admin['SiteCode'] = $SiteCode
        $admin['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMAdministrativeUser -ExecutionName "Adminuser$($admin.AdminName.Replace('\', ''))" -Properties $admin -NoInvoke).Invoke($admin)
    }

    if ($CollectionSettings)
    {
        $CollectionSettings['SiteCode'] = $SiteCode
        $CollectionSettings['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMCollectionMembershipEvaluationComponent -ExecutionName "CollectionSettings$SiteCode" -Properties $CollectionSettings -NoInvoke).Invoke($CollectionSettings)
    }

    if ($StatusReportingSettings)
    {
        $StatusReportingSettings['SiteCode'] = $SiteCode
        $StatusReportingSettings['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMStatusReportingComponent -ExecutionName "CMStatusReportingComponent$SiteCode" -Properties $StatusReportingSettings -NoInvoke).Invoke($StatusReportingSettings)
    }

    foreach ($dg in $DistributionPointGroups)
    {
        CMDistributionGroup ($dg.DistributionGroup -replace '\W')
        {
            SiteCode             = $SiteCode
            DistributionGroup    = $dg.DistributionGroup
            Ensure               = 'Present'
            PsDscRunAsCredential = $SccmInstallAccount
        }

        foreach ($dp in $dg.DistributionPoints)
        {
            $dp['SiteCode'] = $SiteCode
            $dp['SiteServerName'] = $node.NodeName
            $dp['PsDscRunAsCredential'] = $SccmInstallAccount
            $dp['DependsOn'] = '[CMDistributionGroup]{0}' -f ($dg.DistributionGroup -replace '\W')
            (Get-DscSplattedResource -ResourceName CMDistributionPoint -ExecutionName "$($dg.DistributionGroup -replace '\W')DP$((New-Guid).Guid)" -Properties $dp -NoInvoke).Invoke($dp)
        }

        if ($dg.Members)
        {
            $dg.Members['SiteCode'] = $SiteCode
            $dg.Members['DistributionPoint'] = $node.NodeName
            $dg.Members['PsDscRunAsCredential'] = $SccmInstallAccount
            $dg.Members['DependsOn'] = '[CMDistributionGroup]{0}' -f ($dg.DistributionGroup -replace '\W')
            (Get-DscSplattedResource -ResourceName CMDistributionPointGroupMembers -ExecutionName "$($dg.DistributionGroup -replace '\W')Members" -Properties $dg.Members -NoInvoke).Invoke($dg.Members)
        }
    }

    if ($ManagementPoint)
    {
        $ManagementPoint['SiteCode'] = $SiteCode
        $ManagementPoint['SiteServerName'] = $node.NodeName
        $ManagementPoint['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMManagementPoint -ExecutionName "ManagementPoint$($SiteName -replace '\W')" -Properties $ManagementPoint -NoInvoke).Invoke($ManagementPoint)
    }

    if ($SoftwareUpdatePoint)
    {
        $SoftwareUpdatePoint['SiteCode'] = $SiteCode
        $SoftwareUpdatePoint['SiteServerName'] = $node.NodeName
        $SoftwareUpdatePoint['PsDscRunAsCredential'] = $SccmInstallAccount
        (Get-DscSplattedResource -ResourceName CMSoftwareUpdatePoint -ExecutionName "UpdatePoint$($SiteName -replace '\W')" -Properties $SoftwareUpdatePoint -NoInvoke).Invoke($SoftwareUpdatePoint)
    }

    if ($SoftwareUpdatePointComponent)
    {
        $SoftwareUpdatePointComponent['SiteCode'] = $SiteCode
        $SoftwareUpdatePointComponent['PsDscRunAsCredential'] = $SccmInstallAccount
        if (-not $SoftwareUpdatePointComponent.ContainsKey('DefaultWsusServer'))
        {
            $SoftwareUpdatePointComponent['DefaultWsusServer'] = $node.NodeName
        }
        (Get-DscSplattedResource -ResourceName CMSoftwareUpdatePointComponent -ExecutionName "UpdatePointConfig$($SiteName -replace '\W')" -Properties $SoftwareUpdatePointComponent -NoInvoke).Invoke($SoftwareUpdatePointComponent)
    }
}
