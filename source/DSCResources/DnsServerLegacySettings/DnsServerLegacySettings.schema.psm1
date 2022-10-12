configuration DnsServerLegacySettings {
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param (
        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $DnsServer = 'localhost',

        [Parameter(ParameterSetName='NoDependsOn')]
        [uint32]
        $LogLevel,

        [Parameter(ParameterSetName='NoDependsOn')]
        [bool]
        $DisjointNets,

        [Parameter(ParameterSetName='NoDependsOn')]
        [bool]
        $NoForwarderRecursion,

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

    $executionName = 'DnsServerSettingLegacy'
    (Get-DscSplattedResource -ResourceName DnsServerSettingLegacy -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
