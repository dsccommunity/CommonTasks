configuration OfficeOnlineServerMachineConfig
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]

    param (
        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String[]]
        $Roles,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $MachineToJoin,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OfficeOnlineServerDsc

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

    $exeutionName = "$($node.Name)_FarmJoin"
    (Get-DscSplattedResource -ResourceName OfficeOnlineServerMachine -ExecutionName $exeutionName -Properties $param -NoInvoke).Invoke($param)

}
