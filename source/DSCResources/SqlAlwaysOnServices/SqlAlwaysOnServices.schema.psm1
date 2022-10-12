configuration SqlAlwaysOnServices {
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param (
        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $SqlInstanceName = 'MSSQLSERVER',

        [Parameter(ParameterSetName='NoDependsOn')]
        [int]
        $RestartTimeout,

        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $ServerName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $Ensure,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName SqlServerDsc

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

    if (-not $param.ContainsKey('Ensure'))
    {
        $param.Add('Ensure', 'Present')
    }

    $param.InstanceName = $SqlInstanceName
    $param.Remove('SqlInstanceName')

    $executionName = "$($ServerName)_$($InstanceName)"
    (Get-DscSplattedResource -ResourceName SqlAlwaysOnService -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
