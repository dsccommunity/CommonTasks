configuration MmaAgent
{
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [string]
        $WorkspaceId,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [pscredential]
        $WorkspaceKey,

        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $ProxyUri,

        [Parameter(ParameterSetName='NoDependsOn')]
        [pscredential]
        $ProxyCredential,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName MmaDsc

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

    (Get-DscSplattedResource -ResourceName WorkspaceConfiguration -ExecutionName MmaConfig -Properties $param -NoInvoke).Invoke($param)
}
