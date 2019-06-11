Configuration DscLcmMaintenanceWindows {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$MaintenanceWindow
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($window in $MaintenanceWindow.GetEnumerator())
    {
        xRegistry "StartTime_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Name)"
            ValueName = 'StartTime'
            ValueData = $window.StartTime
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }

        xRegistry "Timespan_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Name)"
            ValueName = 'Timespan'
            ValueData = $window.Timespan
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}