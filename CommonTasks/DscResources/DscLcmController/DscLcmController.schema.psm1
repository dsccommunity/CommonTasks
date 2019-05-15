$dscLcmPostponeScript = @'
$path = Join-Path -Path ([System.Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'Dsc\LcmController'
Start-Transcript -Path "$path\LcmPostpone.log" -Append

$currentLcmSettings = Get-DscLocalConfigurationManager
$maxConsistencyCheckInterval = if ($currentLcmSettings.ConfigurationModeFrequencyMins -eq 30) #44640)
{
    44639 #value must be changed in order to reset the LCM timer
}
else
{
    44640 #minutes for 31 days
}

$maxRefreshInterval = if ($currentLcmSettings.RefreshFrequencyMins -eq 30) #44640)
{
    44639 #value must be changed in order to reset the LCM timer
}
else
{
    44640 #minutes for 31 days
}

$metaMofFolder = mkdir -Path "$path\MetaMof" -Force
$mofFile = Copy-Item -Path C:\Windows\System32\Configuration\MetaConfig.mof -Destination "$path\MetaMof\localhost.meta.mof" -PassThru
$content = Get-Content -Path $mofFile.FullName -Raw -Encoding Unicode

$pattern = '(ConfigurationModeFrequencyMins +=)( +\d+)(;)'
$content = $content -replace $pattern, ('$1 {0}$3' -f $maxConsistencyCheckInterval)

$pattern = '(RefreshFrequencyMins +=)( +\d+)(;)'
$content = $content -replace $pattern, ('$1 {0}$3' -f $maxRefreshInterval)

$content | Out-File -FilePath $mofFile.FullName -Encoding unicode

Set-DscLocalConfigurationManager -Path $metaMofFolder -Verbose

"$(Get-Date) - Postponed LCM" | Add-Content -Path "$path\LcmSummery.log"

Stop-Transcript
'@

$dscLcmControlScript = @'
$path = Join-Path -Path ([System.Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'Dsc\LcmController'
Start-Transcript -Path "$path\LcmController.log" -Append

$namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
$className = 'MSFT_DSCLocalConfigurationManager'

$configurationMode = (Get-DscLocalConfigurationManager).ConfigurationMode
$doConsistencyCheck = $false
$doRefresh = $false
$inMaintenanceWindow = $false

$currentTime = Get-Date

$maintenanceWindows = Get-ChildItem -Path HKLM:\SOFTWARE\DscLcmControl\MaintenanceWindows
$consistencyCheckIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name ConsistencyCheckIntervalOverride
$refreshIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name RefreshIntervalOverride

[datetime]$lastConsistencyCheck = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name LastConsistencyCheck
}
catch {
    Get-Date -Date 0
}
[timespan]$consistencyCheckInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name ConsistencyCheckInterval

[datetime]$lastRefresh = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name lastRefresh
}
catch {
    Get-Date -Date 0
}
[timespan]$refreshInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name RefreshInterval

$maintenanceWindowOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmControl -Name MaintenanceWindowOverride 
if ($maintenanceWindows) {
    $inMaintenanceWindow = foreach ($maintenanceWindow in $maintenanceWindows) {
        Write-Host "Reading maintenance window '$($maintenanceWindow.PSChildName)'"
        [datetime]$maintenanceWindowStartTime = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name MaintenanceWindowStartTime
        [timespan]$maintenanceWindowTimespan = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name MaintenanceWindowTimespan
        [datetime]$maintenanceWindowEndTime = $maintenanceWindowStartTime + $maintenanceWindowTimespan

        Write-Host "Maintenance window: $($maintenanceWindowStartTime) - $($maintenanceWindowEndTime)."
        if ($currentTime -gt $maintenanceWindowStartTime -and $currentTime -lt $maintenanceWindowEndTime) {
            Write-Host "Current time '$currentTime' is in maintenance window '$($maintenanceWindow.PSChildName)'"

            Write-Host "IN MAINTENANCE WINDOW: Setting 'inMaintenanceWindow' to 'true' as the current time is in a maintanence windows."
            $true
            break
        }
        else {
            Write-Host "Current time '$currentTime' is not in maintenance window '$($maintenanceWindow.PSChildName)'"
        }
    }
}
else {
    Write-Host "No maintenance windows defined. Setting 'inMaintenanceWindow' to 'true'."
    $inMaintenanceWindow = $true
}
Write-Host

if (-not $inMaintenanceWindow -and $maintenanceWindowOverride) {
    Write-Host "OVERRIDE: 'inMaintenanceWindow' is 'false' but 'maintenanceWindowOverride' is enabled, setting 'inMaintenanceWindow' to 'true'"
    $inMaintenanceWindow = $true
}
elseif (-not $inMaintenanceWindow) {
    Write-Host "NOT IN MAINTENANCE WINDOW: 'inMaintenanceWindow' is 'false'. The current time is not in any of the $($maintenanceWindows.Count) maintenance windows."
}

#always invoke the consistency check if in 'ApplyAndMonitor' but when in 'ApplyAndAutoCorrect' only if in maintenance window.
if ($configurationMode -eq 'ApplyAndAutoCorrect' -and $inMaintenanceWindow) {
    $doConsistencyCheck = $true
}
elseif ($configurationMode -in 'ApplyAndMonitor', 'MonitorOnly') {
    $doConsistencyCheck = $true
}

$doRefresh = $inMaintenanceWindow

#Consistency Check 
$nextConsistencyCheck = $lastConsistencyCheck + $consistencyCheckInterval
Write-Host ""
Write-Host "The previous consistency check was done on '$lastConsistencyCheck', the next one will not triggered before '$nextConsistencyCheck'. ConsistencyCheckInterval is $consistencyCheckInterval."
if ($currentTime -gt $nextConsistencyCheck) {
    Write-Host 'It is time to trigger a consistency check per the defined interval.'
    $doConsistencyCheck = $doConsistencyCheck -band 1
}
else {
    if ($consistencyCheckIntervalOverride) {
        Write-Host "OVERRIDE: It is NOT time to trigger a consistency check per the defined interval but 'ConsistencyCheckIntervalOverride' is enabled."
        $doConsistencyCheck = $doConsistencyCheck -band 1
    }
    else {
        Write-Host 'It is NOT time to trigger a consistency check per the defined interval.'
        $doConsistencyCheck = $doConsistencyCheck -band 0
    }
}
Write-Host

#Refresh Check 
$nextRefresh = $lastRefresh + $refreshInterval
Write-Host ""
Write-Host "The previous refresh check was done on '$lastRefresh', the next one will not triggered before '$nextRefresh'. RefreshInterval is $refreshInterval."
if ($currentTime -gt $nextRefresh) {
    Write-Host 'It is time to trigger a refresh check per the defined interval.'
    $doRefresh = $doRefresh -band 1
}
else {
    if ($refreshIntervalOverride) {
        Write-Host "OVERRIDE: It is NOT time to trigger a consistency check per the defined interval but 'RefreshIntervalOverride' is enabled."
        $doRefresh = $doRefresh -band 1
    }
    else {
        Write-Host 'It is NOT time to trigger a refresh per the defined interval.'
        $doRefresh = $doRefresh -band 0
    }
}
Write-Host

if ($doConsistencyCheck) {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]1 } -ErrorAction Stop
        $dscLcmControl = Get-Item -Path HKLM:\SOFTWARE\DscLcmControl
        Set-ItemProperty -Path $dscLcmControl.PSPath -Name LastConsistencyCheck -Value (Get-Date) -Type String -Force
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
    }
}
else {
    Write-Host "NO ACTION: 'doConsistencyCheck' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
}

if ($doRefresh) {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags'5' (Pull and Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]5 } -ErrorAction Stop
        $dscLcmControl = Get-Item -Path HKLM:\SOFTWARE\DscLcmControl
        Set-ItemProperty -Path $dscLcmControl.PSPath -Name LastRefresh -Value (Get-Date) -Type String -Force
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
    }
}
else {
    Write-Host "NO ACTION: 'doRefresh' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '5' (Pull and Consistency Check)."
}

"$(Get-Date) - LcmController: doConsistencyCheck = '$doConsistencyCheck', doRefresh = '$doRefresh'" | Add-Content -Path "$path\LcmSummery.log"
Stop-Transcript
'@

Configuration DscLcmController {
    Param(
        [Parameter(Mandatory)]
        [timespan]$ConsistencyCheckInterval,
        
        [bool]$ConsistencyCheckIntervalOverride,

        [Parameter(Mandatory)]
        [timespan]$RefreshInterval,
        
        [bool]$RefreshIntervalOverride,

        [Parameter(Mandatory)]
        [timespan]$ControllerInterval,

        [bool]$MaintenanceWindowOverride
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.6.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.3.0.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    xRegistry DscLcmControl_ConsistencyCheckInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'ConsistencyCheckInterval'
        ValueData = $ConsistencyCheckInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_ConsistencyCheckIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'ConsistencyCheckIntervalOverride'
        ValueData = [int]$ConsistencyCheckIntervalOverride
        ValueType = 'DWORD'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_RefreshInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'RefreshInterval'
        ValueData = $RefreshInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_RefreshIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'RefreshIntervalOverride'
        ValueData = [int]$RefreshIntervalOverride
        ValueType = 'DWORD'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_ControllerInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'ControllerInterval'
        ValueData = $ControllerInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_MaintenanceWindowOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl'
        ValueName = 'MaintenanceWindowOverride'
        ValueData = [int]$MaintenanceWindowOverride
        ValueType = 'DWORD'
        Ensure    = 'Present'
        Force     = $true
    }

    File DscLcmPostponeScript
    {
        Ensure = 'Present'
        Type = 'File'
        DestinationPath = 'C:\ProgramData\Dsc\LcmController\LcmPostpone.ps1'
        Contents = $dscLcmPostponeScript
    }
    
    ScheduledTask DscPostponeTask
    {
        DependsOn                 = '[File]DscLcmPostponeScript'
        TaskName                  = 'DscLcmPostpone'
        TaskPath                  = '\DscController'
        ActionExecutable          = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        ActionArguments           = '-File C:\ProgramData\Dsc\LcmController\LcmPostpone.ps1'
        ScheduleType              = 'Once'
        RepeatInterval            = $ControllerInterval
        RepetitionDuration        = 'Indefinitely'
        StartTime                 = (Get-Date)
    }

    File DscLcmControlScript
    {
        Ensure = 'Present'
        Type = 'File'
        DestinationPath = 'C:\ProgramData\Dsc\LcmController\LcmControl.ps1'
        Contents = $dscLcmControlScript
    }
    
    ScheduledTask DscControlTask
    {
        DependsOn                 = '[File]DscLcmControlScript'
        TaskName                  = 'DscLcmControl'
        TaskPath                  = '\DscController'
        ActionExecutable          = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        ActionArguments           = '-File C:\ProgramData\Dsc\LcmController\LcmControl.ps1'
        ScheduleType              = 'Once'
        RepeatInterval            = $ControllerInterval
        RepetitionDuration        = 'Indefinitely'
        StartTime                 = (Get-Date)
    }  
}
