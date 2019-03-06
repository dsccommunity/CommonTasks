Configuration DscLcmMaintenanceWindow {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$MaintenanceWindow
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.5.0.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($window in $MaintenanceWindow.GetEnumerator())
    {
        xRegistry "MaintenanceWindowStartTime_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Name)"
            ValueName = 'MaintenanceWindowStartTime'
            ValueData = $window.MaintenanceWindowStartTime
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }

        xRegistry "MaintenanceWindowTimespan_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Name)"
            ValueName = 'MaintenanceWindowTimespan'
            ValueData = $window.MaintenanceWindowTimespan
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}