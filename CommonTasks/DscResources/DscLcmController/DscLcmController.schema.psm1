$dscLcmPostponeScript = @'
$writeTranscripts = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name WriteTranscripts
$path = Join-Path -Path ([System.Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'Dsc\LcmController'
if ($writeTranscripts) {
    Start-Transcript -Path "$path\LcmPostpone.log" -Append
}

$currentLcmSettings = Get-DscLocalConfigurationManager
$maxConsistencyCheckInterval = if ($currentLcmSettings.ConfigurationModeFrequencyMins -eq 30) { #44640)
    44639 #value must be changed in order to reset the LCM timer
}
else {
    44640 #minutes for 31 days
}

$maxRefreshInterval = if ($currentLcmSettings.RefreshFrequencyMins -eq 30) { #44640)
    44639 #value must be changed in order to reset the LCM timer
}
else {
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

"$(Get-Date) - Postponed LCM" | Add-Content -Path "$path\LcmPostponeSummery.log"

Stop-Transcript
'@

$dscLcmControlScript = @'
$writeTranscripts = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name WriteTranscripts
$path = Join-Path -Path ([System.Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'Dsc\LcmController'
if ($writeTranscripts) {
    Start-Transcript -Path "$path\LcmController.log" -Append
}

$namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
$className = 'MSFT_DSCLocalConfigurationManager'

$configurationMode = (Get-DscLocalConfigurationManager).ConfigurationMode
$doConsistencyCheck = $false
$doRefresh = $false
$inMaintenanceWindow = $false

$currentTime = Get-Date

$maintenanceWindows = Get-ChildItem -Path HKLM:\SOFTWARE\DscLcmController\MaintenanceWindows
$consistencyCheckIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name ConsistencyCheckIntervalOverride
$refreshIntervalOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name RefreshIntervalOverride

[datetime]$lastConsistencyCheck = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name LastConsistencyCheck
}
catch {
    Get-Date -Date 0
}
[timespan]$consistencyCheckInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name ConsistencyCheckInterval

[datetime]$lastRefresh = try {
    Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name lastRefresh
}
catch {
    Get-Date -Date 0
}
[timespan]$refreshInterval = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name RefreshInterval

$maintenanceWindowOverride = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscLcmController -Name MaintenanceWindowOverride 
if ($maintenanceWindows) {
    $inMaintenanceWindow = foreach ($maintenanceWindow in $maintenanceWindows) {
        Write-Host "Reading maintenance window '$($maintenanceWindow.PSChildName)'"
        [datetime]$startTime = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name StartTime
        [timespan]$timespan = Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name Timespan
        [string]$dayOfWeek = try {
            Get-ItemPropertyValue -Path $maintenanceWindow.PSPath -Name DayOfWeek
        }
        catch { }
        [datetime]$endTime = $startTime + $timespan

        if ($dayOfWeek) {
            if ((Get-Date).DayOfWeek -ne $dayOfWeek) {
                Write-Host "DayOfWeek is set to '$dayOfWeek'. Current day of week is '$((Get-Date).DayOfWeek)', maintenance window does not apply"
                continue
            }
            else {
                Write-Host "Maintenance Window is configured for week day '$dayOfWeek' which is the current day of week."
            }
        }

        Write-Host "Maintenance window: $($startTime) - $($endTime)."
        if ($currentTime -gt $startTime -and $currentTime -lt $endTime) {
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
    Write-Host
    Write-Host "Setting 'doConsistencyCheck' to 'true' as the LCM is in '$((Get-DscLocalConfigurationManager).ConfigurationMode)' mode"
    $doConsistencyCheck = $true
}

$doRefresh = $inMaintenanceWindow

#Consistency Check 
$nextConsistencyCheck = $lastConsistencyCheck + $consistencyCheckInterval
Write-Host ""
Write-Host "The previous consistency check was done on '$lastConsistencyCheck', the next one will not be triggered before '$nextConsistencyCheck'. ConsistencyCheckInterval is $consistencyCheckInterval."
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

$consistencyCheckErrors = $false
$refreshErrors = $false
if ($doConsistencyCheck) {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]1 } -ErrorAction Stop | Out-Null
        $dscLcmControl = Get-Item -Path HKLM:\SOFTWARE\DscLcmController
        Set-ItemProperty -Path $dscLcmControl.PSPath -Name LastConsistencyCheck -Value (Get-Date) -Type String -Force
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
        $consistencyCheckErrors = $true
    }
}
else {
    Write-Host "NO ACTION: 'doConsistencyCheck' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '1' (Consistency Check)."
}

if ($doRefresh) {
    Write-Host "ACTION: Invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags'5' (Pull and Consistency Check)."
    try {
        Invoke-CimMethod -ClassName $className -Namespace $namespace -MethodName PerformRequiredConfigurationChecks -Arguments @{ Flags = [uint32]5 } -ErrorAction Stop | Out-Null
        $dscLcmControl = Get-Item -Path HKLM:\SOFTWARE\DscLcmController
        Set-ItemProperty -Path $dscLcmControl.PSPath -Name LastRefresh -Value (Get-Date) -Type String -Force
    }
    catch {
        Write-Error "Error invoking 'PerformRequiredConfigurationChecks'. The message is: '$($_.Exception.Message)'"
        $refreshErrors = $true
    }
}
else {
    Write-Host "NO ACTION: 'doRefresh' is false, not invoking Cim Method 'PerformRequiredConfigurationChecks' with Flags '5' (Pull and Consistency Check)."
}

$logItem = [pscustomobject]@{
    CurrentTime                      = Get-Date
    InMaintenanceWindow              = [int]$inMaintenanceWindow
    DoConsistencyCheck               = $doConsistencyCheck
    DoRefresh                        = $doRefresh

    LastConsistencyCheck             = $lastConsistencyCheck
    ConsistencyCheckInterval         = $consistencyCheckInterval
    ConsistencyCheckIntervalOverride = $consistencyCheckIntervalOverride
    ConsistencyCheckErrors           = $consistencyCheckErrors

    LastRefresh                      = $lastRefresh
    RefreshInterval                  = $refreshInterval
    RefreshIntervalOverride          = $refreshIntervalOverride
    RefreshErrors                    = $refreshErrors
    
} | Export-Csv -Path "$path\LcmControlSummery.txt" -Append

if ($writeTranscripts) {
    Stop-Transcript
}
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

        [bool]$MaintenanceWindowOverride,

        [bool]$WriteTranscripts
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    xRegistry DscLcmControl_ConsistencyCheckInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'ConsistencyCheckInterval'
        ValueData = $ConsistencyCheckInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_ConsistencyCheckIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'ConsistencyCheckIntervalOverride'
        ValueData = [int]$ConsistencyCheckIntervalOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_RefreshInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'RefreshInterval'
        ValueData = $RefreshInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_RefreshIntervalOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'RefreshIntervalOverride'
        ValueData = [int]$RefreshIntervalOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_ControllerInterval {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'ControllerInterval'
        ValueData = $ControllerInterval
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_MaintenanceWindowOverride {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'MaintenanceWindowOverride'
        ValueData = [int]$MaintenanceWindowOverride
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscLcmControl_WriteTranscripts {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmController'
        ValueName = 'WriteTranscripts'
        ValueData = [int]$WriteTranscripts
        ValueType = 'DWord'
        Ensure    = 'Present'
        Force     = $true
    }

    File DscLcmPostponeScript {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = 'C:\ProgramData\Dsc\LcmController\LcmPostpone.ps1'
        Contents        = $dscLcmPostponeScript
    }
    
    ScheduledTask DscPostponeTask {
        DependsOn          = '[File]DscLcmPostponeScript'
        TaskName           = 'DscLcmPostpone'
        TaskPath           = '\DscController'
        ActionExecutable   = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        ActionArguments    = '-File C:\ProgramData\Dsc\LcmController\LcmPostpone.ps1'
        ScheduleType       = 'Once'
        RepeatInterval     = $ControllerInterval
        RepetitionDuration = 'Indefinitely'
        StartTime          = (Get-Date)
    }

    File DscLcmControlScript {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = 'C:\ProgramData\Dsc\LcmController\LcmController.ps1'
        Contents        = $dscLcmControlScript
    }
    
    ScheduledTask DscControlTask {
        DependsOn          = '[File]DscLcmControlScript'
        TaskName           = 'DscLcmController'
        TaskPath           = '\DscController'
        ActionExecutable   = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
        ActionArguments    = '-File C:\ProgramData\Dsc\LcmController\LcmController.ps1'
        ScheduleType       = 'Once'
        RepeatInterval     = $ControllerInterval
        RepetitionDuration = 'Indefinitely'
        StartTime          = (Get-Date)
    }  
}
