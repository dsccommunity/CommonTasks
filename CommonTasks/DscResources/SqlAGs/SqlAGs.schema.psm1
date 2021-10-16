configuration SqlAGs {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$AGs
    )

    <#
    InstanceName = [string]
    Name = [string]
    ServerName = [string]
    [AutomatedBackupPreference = [string]{ None | Primary | Secondary | SecondaryOnly }]
    [AvailabilityMode = [string]{ AsynchronousCommit | SynchronousCommit }]
    [BackupPriority = [UInt32]]
    [BasicAvailabilityGroup = [bool]]
    [ConnectionModeInPrimaryRole = [string]{ AllowAllConnections | AllowReadWriteConnections }]
    [ConnectionModeInSecondaryRole = [string]{ AllowAllConnections | AllowNoConnections | AllowReadIntentConnectionsOnly }]
    [DatabaseHealthTrigger = [bool]]
    [DependsOn = [string[]]]
    [DtcSupportEnabled = [bool]]
    [EndpointHostName = [string]]
    [Ensure = [string]{ Absent | Present }]
    [FailoverMode = [string]{ Automatic | Manual }]
    [FailureConditionLevel = [string]{ OnAnyQualifiedFailureCondition | OnCriticalServerErrors | OnModerateServerErrors | OnServerDown | OnServerUnresponsive }]
    [HealthCheckTimeout = [UInt32]]
    [ProcessOnlyOnActiveNode = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
    #>
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($ag in $AGs)
    {
        if (-not $ag.InstanceName)
        {
            $ag.InstanceName = $DefaultInstanceName
        }

        if(-not $ag.Ensure)
        {
            $ag.Ensure = 'Present'
        }

        $executionName = "$($ag.InstanceName)_$($ag.Name)"
        (Get-DscSplattedResource -ResourceName SqlAG -ExecutionName $executionName -Properties $ag -NoInvoke).Invoke($ag)
    }
}
