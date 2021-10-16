configuration SqlAGReplicas {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Replicas
    )

    <#
    AvailabilityGroupName = [string]
    InstanceName = [string]
    Name = [string]
    ServerName = [string]
    [AvailabilityMode = [string]{ AsynchronousCommit | SynchronousCommit }]
    [BackupPriority = [UInt32]]
    [ConnectionModeInPrimaryRole = [string]{ AllowAllConnections | AllowReadWriteConnections }]
    [ConnectionModeInSecondaryRole = [string]{ AllowAllConnections | AllowNoConnections | AllowReadIntentConnectionsOnly }]
    [DependsOn = [string[]]]
    [EndpointHostName = [string]]
    [Ensure = [string]{ Absent | Present }]
    [FailoverMode = [string]{ Automatic | Manual }]
    [PrimaryReplicaInstanceName = [string]]
    [PrimaryReplicaServerName = [string]]
    [ProcessOnlyOnActiveNode = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
    [ReadOnlyRoutingConnectionUrl = [string]]
    [ReadOnlyRoutingList = [string[]]]
    #>
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($replica in $Replicas)
    {
        if (-not $replica.InstanceName)
        {
            $replica.InstanceName = $DefaultInstanceName
        }

        if(-not $replica.Ensure)
        {
            $replica.Ensure = 'Present'
        }

        $executionName = "$($replica.InstanceName)_$($replica.AvailabilityGroupName)_$($replica.Name)"
        (Get-DscSplattedResource -ResourceName SqlAGReplica -ExecutionName $executionName -Properties $replica -NoInvoke).Invoke($replica)
    }
}
