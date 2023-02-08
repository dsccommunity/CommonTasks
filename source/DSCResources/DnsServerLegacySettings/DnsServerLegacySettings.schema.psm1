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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    $PSBoundParameters.Remove('InstanceName')
    $PSBoundParameters.Remove('DependsOn')

    $executionName = 'DnsServerSettingLegacy'
    (Get-DscSplattedResource -ResourceName DnsServerSettingLegacy -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
