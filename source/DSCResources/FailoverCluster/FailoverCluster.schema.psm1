configuration FailoverCluster
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $StaticIPAddress,

        [Parameter()]
        [System.String[]]
        $IgnoreNetwork,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [Parameter()]
        [ValidateSet('NodeMajority', 'NodeAndDiskMajority', 'NodeAndFileShareMajority', 'NodeAndCloudMajority', 'DiskOnly')]
        [System.String]
        $QuorumType,

        [Parameter()]
        [System.String]
        $QuorumResource,

        [Parameter()]
        [hashtable[]]
        $Disks,

        [Parameter()]
        [hashtable[]]
        $Networks,

        [Parameter()]
        [switch]
        $Join,

        [Parameter()]
        [int]
        $WaitForClusterRetryIntervalSec = 10,

        [Parameter()]
        [int]
        $WaitForClusterRetryCount = 60,

        [Parameter()]
        [string]
        $DomainName,

        [Parameter()]
        [string]
        $OrganizationalUnitDn
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName FailoverClusterDsc
    Import-DscResource -ModuleName ActiveDirectoryDsc

    WindowsFeature RSATADFeatures
    {
        Name   = 'RSAT-AD-PowerShell'
        Ensure = 'Present'
    }

    WindowsFeature ClusterFeatures
    {
        Name      = 'Failover-Clustering'
        Ensure    = 'Present'
        DependsOn = '[WindowsFeature]RSATADFeatures'
    }

    if ($Join)
    {
        WaitForCluster WaitForCluster
        {
            Name             = $Name
            RetryIntervalSec = $WaitForClusterRetryIntervalSec
            RetryCount       = $WaitForClusterRetryCount
            DependsOn        = '[WindowsFeature]ClusterFeatures'
        }

        Cluster JoinSecondNodeToCluster
        {
            Name                          = $Name
            DomainAdministratorCredential = $DomainAdministratorCredential
            DependsOn                     = '[WaitForCluster]WaitForCluster'
        }
    }
    else
    {
        $parameters = @{
            Name                          = $Name
            DomainAdministratorCredential = $DomainAdministratorCredential
            StaticIPAddress               = $StaticIPAddress
        }

        if ($IgnoreNetwork.Count -gt 0)
        {
            $parameters['IgnoreNetwork'] = $IgnoreNetwork
        }

        (Get-DscSplattedResource -ResourceName Cluster -ExecutionName NewCluster -Properties $parameters -NoInvoke).Invoke($parameters)
    }

    foreach ($disk in $Disks)
    {
        ClusterDisk $disk.Number
        {
            Number = $disk.Number
            Label  = $disk.Label
        }
    }

    foreach ($network in $Networks)
    {
        $net = "$($network.Address)__$($network.AddressMask)" -replace '\(|\)|\.|:| ', '_'

        ClusterNetwork $net
        {
            Address     = $network.Address
            AddressMask = $network.AddressMask
            Name        = $network.Name
            Role        = $network.Role
            Metric      = $network.Metric
        }
    }

    if (-not $Join)
    {
        if ($QuorumType -eq 'NodeMajority')
        {
            ClusterQuorum ClusterQuorum
            {
                IsSingleInstance = 'Yes'
                Type             = $QuorumType
            }
        }
        elseif ($QuorumResource)
        {
            ClusterQuorum ClusterQuorum
            {
                IsSingleInstance = 'Yes'
                Type             = $QuorumType
                Resource         = $QuorumResource
            }
        }
    }

    if ($OrganizationalUnitDn)
    {
        #This is required in order to create cluster roles. When creating a cluster role
        #the cluster service is creating the needed computer accounts.
        ADObjectPermissionEntry GrantAccessToClusterAccount
        {
            Path                               = $OrganizationalUnitDn
            IdentityReference                  = "$DomainName\$($Name)$"
            ActiveDirectoryRights              = 'GenericAll'
            AccessControlType                  = 'Allow'
            ObjectType                         = '00000000-0000-0000-0000-000000000000'
            ActiveDirectorySecurityInheritance = 'None'
            InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
            PsDscRunAsCredential               = $DomainAdministratorCredential
        }
    }
}
