configuration Cluster
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
        [switch]
        $Join,

        [Parameter()]
        [string]
        $DomainName,

        [Parameter()]
        [string]
        $OrganizationalUnitDn
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xFailoverCluster
    Import-DscResource -ModuleName ActiveDirectoryDsc

    if ($Join) {
        xWaitForCluster WaitForCluster {
            Name             = $Name
            RetryIntervalSec = 10
            RetryCount       = 60
        }

        xCluster JoinSecondNodeToCluster {
            Name                          = $Name
            DomainAdministratorCredential = $DomainAdministratorCredential
            DependsOn                     = '[xWaitForCluster]WaitForCluster'
        } 
    }
    else {
        xCluster NewCluster {
            Name                          = $Name
            DomainAdministratorCredential = $DomainAdministratorCredential
            StaticIPAddress               = $StaticIPAddress
        }
    }

    foreach ($disk in $Disks) {
        xClusterDisk $disk.Number {
            Number = $disk.Number
            Label  = $disk.Label
        }
    }

    if (-not $Join) {
        xClusterQuorum ClusterQuorum {
            IsSingleInstance = 'Yes'
            Type             = $QuorumType
            Resource         = $QuorumResource
        }
    }

    if ($OrganizationalUnitDn) {
        #This is required in order to create cluster roles. When creating a cluster role
        #the cluster service is creating the needed computer accounts.
        ADObjectPermissionEntry GrantAccessToClusterAccount {
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
