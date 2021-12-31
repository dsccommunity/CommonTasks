configuration SqlAGReplicas {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
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

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if (-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.AvailabilityGroupName)_$($value.Name)"
        (Get-DscSplattedResource -ResourceName SqlAGReplica -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
