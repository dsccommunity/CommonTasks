Configuration DscLcmMaintenanceWindows {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$MaintenanceWindow
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $modes = 'Weekly', 'Daily', 'Monthly'
    $on = '1st', '2nd', '3rd', '4th', 'last'
    $daysOfWeek = [System.Enum]::GetNames([System.DayOfWeek])

    foreach ($window in $MaintenanceWindow.GetEnumerator()) {
        if ($window.Mode -notin $modes) {
            Write-Error "Mode '$($window.Mode)' of maintenance window '$($window.Name)' is not in the supported modes ('$($modes -join ', ')')."
        }
        
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
        Write-Host "Maintenance Window '$($window.Name)'"

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

        xRegistry "Mode_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Mode)"
            ValueName = 'Mode'
            ValueData = $window.Mode
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }

        xRegistry "Interval_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.Interval)"
            ValueName = 'Interval'
            ValueData = $window.Interval
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }

        xRegistry "On_$($window.Name)" {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\DscLcmControl\MaintenanceWindows\$($window.On)"
            ValueName = 'On'
            ValueData = $window.On
            ValueType = 'String'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}

<#
                                    Daily       Weekly      Monthly
- StartTime                         x           x           x
- Timespan                          x           x           x
- Weekly, Daily, Monthly            Daily       Weekly      Monthly
- DayOfWeek                                     x           x
- Interval                          3           2           2
- On (1st, 2nd, 3rd, 4th, last                              x
#>