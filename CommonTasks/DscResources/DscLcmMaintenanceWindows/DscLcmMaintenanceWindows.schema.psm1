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

<#
                                    Daily       Weekly      Monthly
- StartTime                         x           x           x
- Timespan                          x           x           x
- Weekly, Daily, Monthly            Daily       Weekly      Monthly
- DayOfWeek                                     x           x
- Interval                          3           2           2
- On (1st, 2nd, 3rd, 4th, last                              x
#>