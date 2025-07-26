configuration ExchangeDagProvisioning
{
    param
    (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $ShellCreds,

        [Parameter(Mandatory = $true)]
        [string]
        $DagName,

        [Parameter(Mandatory = $true)]
        [int]
        $AutoDagTotalNumberOfServers,

        [Parameter(Mandatory = $true)]
        [int]
        $AutoDagDatabaseCopiesPerVolume,

        [Parameter(Mandatory = $true)]
        [string]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [string]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Off', 'DagOnly')]
        [string]
        $DatacenterActivationMode,

        [Parameter(Mandatory = $true)]
        [string]
        $WitnessServer,

        [Parameter(Mandatory = $true)]
        [string]
        $WitnessDirectory,

        [Parameter()]
        [bool]
        $ReplayLagManagerEnabled,

        [Parameter()]
        [bool]
        $SkipDagValidation,

        [Parameter(Mandatory = $true)]
        [string]
        $FirstDagMemberName
    )

    #Import required DSC Modules
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ExchangeDsc

    #This first section only configures a single DAG node, the first member of the DAG.
    #The first member of the DAG will be responsible for DAG creation and maintaining its configuration
    if ($Node.NodeName -eq $FirstDagMemberName)
    {
        ExchDatabaseAvailabilityGroup Dag
        {
            Name                           = $DagName
            Credential                     = $ShellCreds
            AutoDagTotalNumberOfServers    = $AutoDagTotalNumberOfServers
            AutoDagDatabaseCopiesPerVolume = $AutoDagDatabaseCopiesPerVolume
            AutoDagDatabasesRootFolderPath = $AutoDagDatabasesRootFolderPath
            AutoDagVolumesRootFolderPath   = $AutoDagVolumesRootFolderPath
            DatacenterActivationMode       = $DatacenterActivationMode
            ManualDagNetworkConfiguration  = $false
            ReplayLagManagerEnabled        = $ReplayLagManagerEnabled
            SkipDagValidation              = $SkipDagValidation
            WitnessDirectory               = $WitnessDirectory
            WitnessServer                  = $WitnessServer
        }

        ExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $DagName
            SkipDagValidation = $true

            DependsOn         = '[ExchDatabaseAvailabilityGroup]Dag'
        }
    }
    else
    {
        #Add this server as member
        ExchWaitForDAG WaitForDag
        {
            Identity   = $DagName
            Credential = $ShellCreds
        }

        ExchDatabaseAvailabilityGroupMember DagMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $DagName
            SkipDagValidation = $true

            DependsOn         = '[ExchWaitForDAG]WaitForDag'
        }
    }
}
