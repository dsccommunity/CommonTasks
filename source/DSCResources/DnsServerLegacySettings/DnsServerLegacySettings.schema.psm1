configuration DnsServerLegacySettings {
    param (
        [Parameter()]
        [string]
        $DnsServer = 'localhost',

        [Parameter()]
        [uint32]
        $LogLevel,

        [Parameter()]
        [bool]
        $DisjointNets,

        [Parameter()]
        [bool]
        $NoForwarderRecursion
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    if ($PSBoundParameters.ContainsKey('InstanceName')) {
        $PSBoundParameters.Remove('InstanceName')
    }

    $executionName = 'DnsServerSettingLegacy'
    (Get-DscSplattedResource -ResourceName DnsServerSettingLegacy -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)
}
