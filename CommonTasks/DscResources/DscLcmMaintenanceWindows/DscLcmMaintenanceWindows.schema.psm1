Configuration DscLcmMaintenanceWindows {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$MaintenanceWindow
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $on = '1st', '2nd', '3rd', '4th', 'last'
    $daysOfWeek = [System.Enum]::GetNames([System.DayOfWeek])

    foreach ($window in $MaintenanceWindow.GetEnumerator()) {
        
        if ($window.DayOfWeek) {
            if ($window.DayOfWeek -notin $daysOfWeek) {
                Write-Error "DayOfWeek '$($window.DayOfWeek)' of maintenance window '$($window.Name)' is not in the supported range ('$($daysOfWeek -join ', ')')."
            }
        }

        if ($window.On) {
            if ($window.On -notin $on) {
                Write-Error "Property 'On' set to '$($window.On)' of maintenance window '$($window.Name)' is not in the supported range ('$($on -join ', ')')."
            }
        }
    }

    foreach ($window in $MaintenanceWindow.GetEnumerator()) {
    
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

        xRegistry "On_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Name)"
            ValueName = 'On'
            ValueData = $window.On
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}
