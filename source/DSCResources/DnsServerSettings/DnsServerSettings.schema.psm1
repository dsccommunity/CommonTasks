configuration DnsServerSettings {
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $DnsServer,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowUpdate,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $BindSecondaries,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $BootMethod,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $RoundRobin,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $RpcProtocol,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $SendPort,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $UpdateOptions,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $XfrConnectTimeout,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableIPv6,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableWinsR,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AdminConfigured,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ReloadException,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $SelfTest,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $LameDelegationTTL,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $ZoneWritebackInterval,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    if ($DependsOn -and -not $Config)
    {
        throw "If DependsOn is specified, the configuration must be indented and passed using the Config parameter."
    }

    if ($Config)
    {
        $param = $Config.Clone()
    }
    else
    {
        $param = $PSBoundParameters
        $param.Remove('InstanceName')
        $param.Remove('DependsOn')
    }

    $executionName = 'DnsServerSetting'
    (Get-DscSplattedResource -ResourceName DnsServerSetting -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
