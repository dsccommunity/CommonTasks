configuration OfficeOnlineServerMachineConfig
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]

    param (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $Roles,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OfficeOnlineServerDsc

    $param = $PSBoundParameters
    $param.Remove('InstanceName')
    $param.Remove('DependsOn')
    $exeutionName = "$($node.Name)_FarmJoin"
    (Get-DscSplattedResource -ResourceName OfficeOnlineServerMachine -ExecutionName $exeutionName -Properties $param -NoInvoke).Invoke($param)

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
