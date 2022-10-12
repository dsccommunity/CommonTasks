configuration OfficeOnlineServerFarmConfig
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param (
        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowCEIP,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowHttp,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CacheLocation,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $CacheSizeInGB,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CertificateName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ClipartEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $DocumentInfoCacheSize,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $EditingEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelAllowExternalData,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelConnectionLifetime,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelPrivateBytesMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelRequestDurationMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelSessionTimeout,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelUdfsAllowed,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelWorkbookSizeMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $ExternalURL,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $FarmOU,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $InternalURL,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $LogLocation,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $LogRetentionInDays,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $LogVerbosity,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $MaxTranslationCharacterCount,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OpenFromUncEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OpenFromUrlEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $Proxy,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Int32]
        $RecycleActiveProcessCount,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $RenderingLocalCacheLocation,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $SSLOffloaded,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $TranslationEnabled,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $TranslationServiceAddress,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $TranslationServiceAppId,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $AllowOutboundHttp,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $S2SCertificateName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $PicturePasteDisabled,

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

    if (-not $param.ExternalUrl -and -not $param.InternalUrl)
    {
        throw 'Either "$ExternalUrl" or "$InternalUrl" must be defined'
    }

    if (-not $param.CertificateName -and -not $param.AllowHttp -and -not $param.SSLOffloaded)
    {
        throw 'Either "$CertificateName" or "$AllowHttp" or "SSLOffloaded" must be defined'
    }
    $exeutionName = "$($node.Name)_FarmCreate"
    (Get-DscSplattedResource -ResourceName OfficeOnlineServerFarm -ExecutionName $exeutionName -Properties $param -NoInvoke).Invoke($param)

}
