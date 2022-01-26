configuration OfficeOnlineServerFarmConfig
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword')]

    param (
        [Parameter()]
        [System.Boolean]
        $AllowCEIP,

        [Parameter()]
        [System.Boolean]
        $AllowHttp,

        [Parameter()]
        [System.Boolean]
        $AllowHttpSecureStoreConnections,

        [Parameter()]
        [System.String]
        $CacheLocation,

        [Parameter()]
        [System.Int32]
        $CacheSizeInGB,

        [Parameter()]
        [System.String]
        $CertificateName,

        [Parameter()]
        [System.Boolean]
        $ClipartEnabled,

        [Parameter()]
        [System.Int32]
        $DocumentInfoCacheSize,

        [Parameter()]
        [System.Boolean]
        $EditingEnabled,

        [Parameter()]
        [System.Boolean]
        $ExcelAllowExternalData,

        [Parameter()]
        [System.Int32]
        $ExcelConnectionLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelExternalDataCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelPrivateBytesMax,

        [Parameter()]
        [System.Int32]
        $ExcelRequestDurationMax,

        [Parameter()]
        [System.Int32]
        $ExcelSessionTimeout,

        [Parameter()]
        [System.Boolean]
        $ExcelUdfsAllowed,

        [Parameter()]
        [System.Boolean]
        $ExcelWarnOnDataRefresh,

        [Parameter()]
        [System.Int32]
        $ExcelWorkbookSizeMax,

        [Parameter()]
        [System.Int32]
        $ExcelMemoryCacheThreshold,

        [Parameter()]
        [System.Int32]
        $ExcelUnusedObjectAgeMax,

        [Parameter()]
        [System.Boolean]
        $ExcelCachingUnusedFiles,

        [Parameter()]
        [System.Boolean]
        $ExcelAbortOnRefreshOnOpenFail,

        [Parameter()]
        [System.Int32]
        $ExcelAutomaticVolatileFunctionCacheLifetime,

        [Parameter()]
        [System.Int32]
        $ExcelConcurrentDataRequestsPerSessionMax,

        [Parameter()]
        [System.String]
        $ExcelDefaultWorkbookCalcMode,

        [Parameter()]
        [System.Boolean]
        $ExcelRestExternalDataEnabled,

        [Parameter()]
        [System.Int32]
        $ExcelChartAndImageSizeMax,

        [Parameter()]
        [System.String]
        $ExternalURL,

        [Parameter()]
        [System.String]
        $FarmOU,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InternalURL,

        [Parameter()]
        [System.String]
        $LogLocation,

        [Parameter()]
        [System.Int32]
        $LogRetentionInDays,

        [Parameter()]
        [System.String]
        $LogVerbosity,

        [Parameter()]
        [System.Int32]
        $MaxMemoryCacheSizeInMB,

        [Parameter()]
        [System.Int32]
        $MaxTranslationCharacterCount,

        [Parameter()]
        [System.Boolean]
        $OpenFromUncEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlEnabled,

        [Parameter()]
        [System.Boolean]
        $OpenFromUrlThrottlingEnabled,

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.Int32]
        $RecycleActiveProcessCount,

        [Parameter()]
        [System.String]
        $RenderingLocalCacheLocation,

        [Parameter()]
        [System.Boolean]
        $SSLOffloaded,

        [Parameter()]
        [System.Boolean]
        $TranslationEnabled,

        [Parameter()]
        [System.String]
        $TranslationServiceAddress,

        [Parameter()]
        [System.String]
        $TranslationServiceAppId,

        [Parameter()]
        [System.Boolean]
        $AllowOutboundHttp,

        [Parameter()]
        [System.Boolean]
        $ExcelUseEffectiveUserName,

        [Parameter()]
        [System.String]
        $S2SCertificateName,

        [Parameter()]
        [System.Boolean]
        $RemovePersonalInformationFromLogs,

        [Parameter()]
        [System.Boolean]
        $PicturePasteDisabled
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OfficeOnlineServerDsc

    if (-not $ExternalUrl -and -not $InternalUrl)
    {
        Write-Error 'Either "$ExternalUrl" or "$InternalUrl" must be defined'
        return
    }

    if (-not $CertificateName -and -not $AllowHttp -and -not $SSLOffloaded)
    {
        Write-Error 'Either "$CertificateName" or "$AllowHttp" or "SSLOffloaded" must be defined'
        return
    }

    $param = $PSBoundParameters
    $param.Remove('InstanceName')
    $exeutionName = "$($node.Name)_FarmCreate"
    (Get-DscSplattedResource -ResourceName OfficeOnlineServerFarm -ExecutionName $exeutionName -Properties $param -NoInvoke).Invoke($param)

}
