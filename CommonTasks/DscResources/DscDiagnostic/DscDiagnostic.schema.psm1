function Get-DscConfigurationVersion {
    $key = Get-Item HKLM:\SOFTWARE\DscTagging
    $hash = @{ }
    foreach ($property in $key.Property) {
        $hash.Add($property, $key.GetValue($property))
    }
    
    New-Object -TypeName PSObject -Property $hash
}

function Get-DscLcmControllerSettings {
    $maintenanceWindows = dir HKLM:\SOFTWARE\DscLcmController\MaintenanceWindows
    $maintenanceWindowHash = @{ }
    foreach ($maintenanceWindow in $maintenanceWindows) {
        $mwHash = @{ }
        foreach ($property in $maintenanceWindow.Property) {
            $mwHash.Add($property, $maintenanceWindow.GetValue($property))
        }
        $maintenanceWindowHash.Add($maintenanceWindow.PSChildName, $mwHash)
    }

    $hash.Add('MaintenanceWindows', $maintenanceWindowHash)

    New-Object -TypeName PSObject -Property $hash
}

function Test-DscConfiguration {
    PSDesiredStateConfiguration\Test-DscConfiguration -Detailed -Verbose
}

function Update-DscConfiguration {
    PSDesiredStateConfiguration\Update-DscConfiguration -Wait -Verbose
}

function Get-DscLocalConfigurationManager {
    PSDesiredStateConfiguration\Get-DscLocalConfigurationManager
}

function Get-DscLcmControllerSummary {
    param(
        [switch]$AutoCorrect,

        [switch]$Refresh,

        [switch]$Monitor,

        [int]$Last = 1000
    )

    
    Import-Csv -Path C:\ProgramData\Dsc\LcmController\LcmControllerSummary.txt | Where-Object {
        if ($AutoCorrect) {
            [bool][int]$_.DoAutoCorrect -eq $AutoCorrect
        }
        else { 
            $true
        }
    } | Where-Object {
        if ($Refresh) {
            [bool][int]$_.DoRefresh -eq $Refresh
        }
        else { 
            $true
        }
    } | Where-Object {
        if ($Monitor) {
            [bool][int]$_.DoMonitor -eq $Monitor
        }
        else { 
            $true
        }
    } | Select-Object -Last $Last
}

function Start-DscConfiguration {
    PSDesiredStateConfiguration\Start-DscConfiguration -UseExisting -Wait -Verbose
}

function Get-DscOperationalEventLog {
    Get-WinEvent -LogName "Microsoft-Windows-Dsc/Operational"    
}

function Get-DscTraceInformation {

    param (
        [int]$Last = 100
    )
    
    if (-not (Get-Module -ListAvailable -Name xDscDiagnostics)) {
        Write-Error "This function required the module 'xDscDiagnostics' to be present on the system"
        return
    }
    
    $failedJobs = Get-xDscOperation -Newest $Last | Where-Object Result -eq 'Failure'
    
    foreach ($failedJob in $failedJobs) {
        if ($failedJob.JobID) {
            Trace-xDscOperation -JobId $failedJob.JobID
        }
        else {
            Trace-xDscOperation -SequenceID $failedJob.SequenceId
        }
    }
}

#-------------------------------------------------------------------------------------------

Configuration DscDiagnostic {

    Import-DscResource -ModuleName JeaDsc

    $visibleFunctions = 'Test-DscConfiguration',
    'Get-DscConfigurationVersion',
    'Update-DscConfiguration',
    'Get-DscLcmControllerSummary',
    'Start-DscConfiguration',
    'Get-DscOperationalEventLog',
    'Get-DscTraceInformation',
    'Get-DscLcmControllerSettings',
    'Get-DscLocalConfigurationManager'

    $functionDefinitions = @()
    foreach ($visibleFunction in $visibleFunctions) {
        $functionDefinitions += @{
            Name        = $visibleFunction
            ScriptBlock = (Get-Command -Name $visibleFunction).ScriptBlock
        } | ConvertTo-Expression
    }

    JeaRoleCapabilities ReadDiagnosticRole
    {
        Path                = 'C:\Program Files\WindowsPowerShell\Modules\DscDiagnostics\RoleCapabilities\ReadDiagnosticsRole.psrc'
        VisibleFunctions    = $visibleFunctions
        FunctionDefinitions = $functionDefinitions
    }
    
    JeaSessionConfiguration DscEndpoint
    {
        Ensure          = 'Present'
        DependsOn       = '[JeaRoleCapabilities]ReadDiagnosticsRole'
        Name            = 'DSC'
        RoleDefinitions = '@{ Everyone = @{ RoleCapabilities = "ReadDiagnosticsRole" } }'
        SessionType     = 'RestrictedRemoteServer'
        ModulesToImport = 'PSDesiredStateConfiguration'
    }
}
