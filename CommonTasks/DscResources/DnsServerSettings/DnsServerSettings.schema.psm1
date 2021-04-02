configuration DnsServerSettings {
    param (
        [Parameter()]
        [string]
        $DnsServer = 'localhost',

        [Parameter()]
        [uint32]
        $AddressAnswerLimit,

        [Parameter()]
        [uint32]
        $AllowUpdate,

        [Parameter()]
        [bool]
        $AutoCacheUpdate,

        [Parameter()]
        [uint32]
        $AutoConfigFileZones,

        [Parameter()]
        [bool]
        $BindSecondaries,

        [Parameter()]
        [uint32]
        $BootMethod,

        [Parameter()]
        [bool]
        $DefaultAgingState,

        [Parameter()]
        [uint32]
        $DefaultNoRefreshInterval,

        [Parameter()]
        [uint32]
        $DefaultRefreshInterval,

        [Parameter()]
        [bool]
        $DisableAutoReverseZones,

        [Parameter()]
        [bool]
        $DisjointNets,

        [Parameter()]
        [uint32]
        $DsPollingInterval,

        [Parameter()]
        [uint32]
        $DsTombstoneInterval,

        [Parameter()]
        [uint32]
        $EDnsCacheTimeout,

        [Parameter()]
        [bool]
        $EnableDirectoryPartitions,

        [Parameter()]
        [uint32]
        $EnableDnsSec,

        [Parameter()]
        [bool]
        $EnableEDnsProbes,

        [Parameter()]
        [uint32]
        $ForwardDelegations,

        [Parameter()]
        [string[]]
        $Forwarders,

        [Parameter()]
        [uint32]
        $ForwardingTimeout,

        [Parameter()]
        [bool]
        $IsSlave,

        [Parameter()]
        [string[]]
        $ListenAddresses,

        [Parameter()]
        [bool]
        $LocalNetPriority,

        [Parameter()]
        [uint32]
        $LogLevel,

        [Parameter()]
        [bool]
        $LooseWildcarding,

        [Parameter()]
        [uint32]
        $MaxCacheTTL,

        [Parameter()]
        [uint32]
        $MaxNegativeCacheTTL,

        [Parameter()]
        [uint32]
        $NameCheckFlag,

        [Parameter()]
        [bool]
        $NoRecursion,

        [Parameter()]
        [uint32]
        $RecursionRetry,

        [Parameter()]
        [uint32]
        $RecursionTimeout,

        [Parameter()]
        [bool]
        $RoundRobin,

        [Parameter()]
        [int16]
        $RpcProtocol,

        [Parameter()]
        [uint32]
        $ScavengingInterval,

        [Parameter()]
        [bool]
        $SecureResponses,

        [Parameter()]
        [uint32]
        $SendPort,

        [Parameter()]
        [bool]
        $StrictFileParsing,

        [Parameter()]
        [uint32]
        $UpdateOptions,

        [Parameter()]
        [bool]
        $WriteAuthorityNS,

        [Parameter()]
        [uint32]
        $XfrConnectTimeout
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    if ($PSBoundParameters.ContainsKey('InstanceName')) {
        $PSBoundParameters.Remove('InstanceName')
    }

    $executionName = 'DnsSettings'
    (Get-DscSplattedResource -ResourceName xDnsServerSetting -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)
}
