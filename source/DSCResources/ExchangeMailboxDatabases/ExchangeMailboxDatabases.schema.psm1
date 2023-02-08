configuration ExchangeMailboxDatabases {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Items
    )

    <#
    Credential = [PSCredential]
    DatabaseCopyCount = [UInt32]
    EdbFilePath = [string]
    LogFolderPath = [string]
    Name = [string]
    Server = [string]
    [AdServerSettingsPreferredServer = [string]]
    [AllowFileRestore = [bool]]
    [AllowServiceRestart = [bool]]
    [AutoDagExcludeFromMonitoring = [bool]]
    [BackgroundDatabaseMaintenance = [bool]]
    [CalendarLoggingQuota = [string]]
    [CircularLoggingEnabled = [bool]]
    [DataMoveReplicationConstraint = [string]{ AllCopies | AllDatacenters | None | SecondCopy | SecondDatacenter }]
    [DeletedItemRetention = [string]]
    [DependsOn = [string[]]]
    [DomainController = [string]]
    [EventHistoryRetentionPeriod = [string]]
    [IndexEnabled = [bool]]
    [IsExcludedFromProvisioning = [bool]]
    [IsExcludedFromProvisioningByOperator = [bool]]
    [IsExcludedFromProvisioningDueToLogicalCorruption = [bool]]
    [IsExcludedFromProvisioningReason = [string]]
    [IssueWarningQuota = [string]]
    [IsSuspendedFromProvisioning = [bool]]
    [JournalRecipient = [string]]
    [MailboxRetention = [string]]
    [MetaCacheDatabaseMaxCapacityInBytes = [Int64]]
    [MountAtStartup = [bool]]
    [OfflineAddressBook = [string]]
    [ProhibitSendQuota = [string]]
    [ProhibitSendReceiveQuota = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [RecoverableItemsQuota = [string]]
    [RecoverableItemsWarningQuota = [string]]
    [RetainDeletedItemsUntilBackup = [bool]]
    [SkipInitialDatabaseMount = [bool]]
    #>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module xExchange

    foreach ($item in $Items)
    {
        $item.Server = $Node.NodeName

        $executionName = $item.Name
        (Get-DscSplattedResource -ResourceName xExchMailboxDatabase -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
