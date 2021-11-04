configuration ExchangeDagProvisioning
{ 
    param
    (
        [Parameter(Mandatory)]
        [PSCredential]$ShellCreds,

        [Parameter(Mandatory)]
        [string]$DagName,

        [Parameter(Mandatory)]
        [int]$AutoDagTotalNumberOfServers,

        [Parameter(Mandatory)]
        [int]$AutoDagDatabaseCopiesPerVolume,

        [Parameter(Mandatory)]
        [string]$AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory)]
        [string]$AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory)]
        [ValidateSet('Off', 'DagOnly')]
        [string]$DatacenterActivationMode, 

        [Parameter(Mandatory)]
        [string]$WitnessServer,

        [Parameter(Mandatory)]
        [string]$WitnessDirectory,

        [Parameter()]
        [bool]$ReplayLagManagerEnabled,

        [Parameter()]
        [bool]$SkipDagValidation,

        [Parameter(Mandatory)]
        [string]$FirstDagMemberName
    )

    #Import required DSC Modules
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xExchange

    #This first section only configures a single DAG node, the first member of the DAG.
    #The first member of the DAG will be responsible for DAG creation and maintaining its configuration
    if ($Node.NodeName -eq $FirstDagMemberName)
    {
        xExchDatabaseAvailabilityGroup Dag
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

        xExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $DagName
            SkipDagValidation = $true

            DependsOn         = '[xExchDatabaseAvailabilityGroup]Dag'
        }
    }
    else
    {
        #Add this server as member
        xExchWaitForDAG WaitForDag
        { 
            Identity   = $DagName
            Credential = $ShellCreds
        }

        xExchDatabaseAvailabilityGroupMember DagMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $DagName
            SkipDagValidation = $true

            DependsOn         = '[xExchWaitForDAG]WaitForDag'
        }
    }
}
