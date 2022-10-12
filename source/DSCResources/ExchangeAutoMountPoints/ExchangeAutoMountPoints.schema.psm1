configuration ExchangeAutoMountPoints {
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param
    (
        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $MinDiskSize = '',

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $UnitSize = '64K',

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $VolumePrefix = 'EXVOL',

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module xExchange

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

    if (-not $param.ContainsKey('Identity'))
    {
        $param.Add('Identity', $Node.NodeName)
        $executionName = $Node.NodeName
    }
    else
    {
        $executionName = $param.Identity
    }

    (Get-DscSplattedResource -ResourceName xExchAutoMountPoint -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)
}
