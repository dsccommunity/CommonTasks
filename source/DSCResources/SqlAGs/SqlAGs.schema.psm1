configuration SqlAGs {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAG

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

        $executionName = "$($value.InstanceName)_$($value.Name)"
        (Get-DscSplattedResource -ResourceName SqlAG -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
