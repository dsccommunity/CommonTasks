configuration DnsServerSettings {
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter()]
        [System.Boolean]
        $AllowUpdate,

        [Parameter()]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter()]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter()]
        [System.Boolean]
        $BindSecondaries,

        [Parameter()]
        [System.UInt32]
        $BootMethod,

        [Parameter()]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter()]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter()]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter()]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter()]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter()]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter()]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter()]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter()]
        [System.Boolean]
        $RoundRobin,

        [Parameter()]
        [System.UInt32]
        $RpcProtocol,

        [Parameter()]
        [System.UInt32]
        $SendPort,

        [Parameter()]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter()]
        [System.UInt32]
        $UpdateOptions,

        [Parameter()]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter()]
        [System.UInt32]
        $XfrConnectTimeout,

        [Parameter()]
        [System.Boolean]
        $EnableIPv6,

        [Parameter()]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter()]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter()]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter()]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter()]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter()]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter()]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter()]
        [System.Boolean]
        $EnableWinsR,

        [Parameter()]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter()]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter()]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter()]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter()]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter()]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter()]
        [System.Boolean]
        $AdminConfigured,

        [Parameter()]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter()]
        [System.Boolean]
        $ReloadException,

        [Parameter()]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter()]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter()]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter()]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter()]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter()]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter()]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter()]
        [System.UInt32]
        $SelfTest,

        [Parameter()]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter()]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter()]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter()]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter()]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter()]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter()]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter()]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter()]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter()]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter()]
        [System.String]
        $LameDelegationTTL,

        [Parameter()]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter()]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter()]
        [System.String]
        $ZoneWritebackInterval
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    if ($PSBoundParameters.ContainsKey('InstanceName')) {
        $PSBoundParameters.Remove('InstanceName')
    }

    $executionName = 'DnsServerSetting'
    (Get-DscSplattedResource -ResourceName DnsServerSetting -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)
}
