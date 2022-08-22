Configuration ScomSettings
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet('Pending', 'AutoReject', 'AutoApprove')]
        [string]
        $ApprovalSetting,

        [Parameter()]
        [hashtable]
        $AlertResolutionSetting,

        [Parameter()]
        [hashtable]
        $DatabaseGroomingSetting,

        [Parameter()]
        [hashtable]
        $DataWarehouseSetting,

        [Parameter()]
        [ValidateSet('AutomaticallySend', 'OptOut', 'PromptBeforeSending')]
        [string]
        $ErrorReportSetting,

        [Parameter()]
        [hashtable]
        $HeartbeatSetting,

        [Parameter()]
        [string]
        $ReportingServerUrl,

        [Parameter()]
        [hashtable]
        $WebAddressSetting
    )

    Import-DscResource -ModuleName cScom

    if (-not [string]::IsNullOrWhiteSpace($ApprovalSetting))
    {
        ScomAgentApprovalSetting Approval
        {
            ApprovalType     = $ApprovalSetting
            IsSingleInstance = 'Yes'
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($ErrorReportSetting))
    {
        ScomErrorReportSetting ErroReporting
        {
            ReportSetting    = $ErrorReportSetting
            IsSingleInstance = 'Yes'
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($ReportingServerUrl))
    {
        ScomReportingSetting ReportUrl
        {
            ReportingServerUrl = $ReportingServerUrl
            IsSingleInstance   = 'Yes'
        }
    }

    if ($null -ne $AlertResolutionSetting)
    {
        $executionName = 'alertresolutionsetting'
        $AlertResolutionSetting.IsSingleInstance = 'Yes'
        (Get-DscSplattedResource -ResourceName ScomAlertResolutionSetting -ExecutionName $executionName -Properties $AlertResolutionSetting -NoInvoke).Invoke($AlertResolutionSetting)
    }

    if ($null -ne $DatabaseGroomingSetting)
    {
        $executionName = 'dbgroomingsetting'
        $DatabaseGroomingSetting.IsSingleInstance = 'Yes'
        (Get-DscSplattedResource -ResourceName ScomDatabaseGroomingSetting -ExecutionName $executionName -Properties $DatabaseGroomingSetting -NoInvoke).Invoke($DatabaseGroomingSetting)
    }

    if ($null -ne $DataWarehouseSetting)
    {
        $executionName = 'datawarehousesetting'
        $DataWarehouseSetting.IsSingleInstance = 'Yes'
        (Get-DscSplattedResource -ResourceName ScomDataWarehouseSetting -ExecutionName $executionName -Properties $DataWarehouseSetting -NoInvoke).Invoke($DataWarehouseSetting)
    }

    if ($null -ne $HeartbeatSetting)
    {
        $executionName = 'heartbeatsetting'
        $HeartbeatSetting.IsSingleInstance = 'Yes'
        (Get-DscSplattedResource -ResourceName ScomHeartbeatSetting -ExecutionName $executionName -Properties $HeartbeatSetting -NoInvoke).Invoke($HeartbeatSetting)
    }

    if ($null -ne $WebAddressSetting)
    {
        $executionName = 'webaddresssetting'
        $WebAddressSetting.IsSingleInstance = 'Yes'
        (Get-DscSplattedResource -ResourceName ScomWebAddressSetting -ExecutionName $executionName -Properties $WebAddressSetting -NoInvoke).Invoke($WebAddressSetting)
    }
}
