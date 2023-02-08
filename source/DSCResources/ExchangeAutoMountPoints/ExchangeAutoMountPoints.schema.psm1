configuration ExchangeAutoMountPoints {
    param
    (
        [Parameter()]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module xExchange

    if (-not $PSBoundParameters.ContainsKey('Identity'))
    {
        $PSBoundParameters.Add('Identity', $Node.NodeName)
        $executionName = $Node.NodeName
    }
    else
    {
        $executionName = $Identity
    }
    $PSBoundParameters.Remove('InstanceName')
    $PSBoundParameters.Remove('DependsOn')


    (Get-DscSplattedResource -ResourceName xExchAutoMountPoint -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
