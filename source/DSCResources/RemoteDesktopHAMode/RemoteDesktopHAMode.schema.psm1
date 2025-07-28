configuration RemoteDesktopHAMode
{
    [CmdletBinding(DefaultParameterSetName = 'NoDependsOn')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'NoDependsOn')]
        [string]
        $ConnectionBroker,

        [Parameter(Mandatory = $true, ParameterSetName = 'NoDependsOn')]
        [string]
        $ClientAccessName,

        [Parameter(Mandatory = $true, ParameterSetName = 'NoDependsOn')]
        [string]
        $DatabaseConnectionString,

        [Parameter(ParameterSetName = 'NoDependsOn')]
        [string]
        $DatabaseSecondaryConnectionString,

        [Parameter(ParameterSetName = 'NoDependsOn')]
        [string]
        $DatabaseFilePath,

        [Parameter(ParameterSetName = 'DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName xRemoteDesktopSessionHost

    if ($DependsOn -and -not $Config)
    {
        throw 'If DependsOn is specified, the configuration must be indented and passed using the Config parameter.'
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
        $param.Remove('PsDscRunAsCredential')
    }

    (Get-DscSplattedResource -ResourceName xRDConnectionBrokerHAMode -ExecutionName RDCBHAMode -Properties $param -NoInvoke).Invoke($param)
}
