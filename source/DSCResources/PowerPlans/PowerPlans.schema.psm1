configuration PowerPlans
{
    param
    (
        [Parameter()]
        [ValidateSet('On', 'Off')]
        [string]
        $Hibernate,

        [Parameter()]
        [hashtable[]]
        $Plans,

        [Parameter()]
        [hashtable[]]
        $Settings
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_PowerPlan

    if (-not [string]::IsNullOrWhiteSpace($Hibernate))
    {
        Script 'pwrplan_hibernate'
        {
            TestScript = {
                $val = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled' -ErrorAction SilentlyContinue

                Write-Verbose "Expected hibernate mode: $using:Hibernate"

                if ($null -ne $val -and $null -ne $val.HibernateEnabled)
                {
                    Write-Verbose "Current hibernate mode: $($val.HibernateEnabled)"

                    if (($using:Hibernate -eq 'On' -and $val.HibernateEnabled -gt 0) -or
                        ($using:Hibernate -eq 'Off' -and $val.HibernateEnabled -eq 0))
                    {
                        return $true
                    }
                }
                return $false
            }
            SetScript  = {
                Write-Verbose "Set Hibernate mode: $using:Hibernate"
                powercfg /HIBERNATE $using:Hibernate
            }
            GetScript  = { return `
                @{
                    result = 'N/A'
                }
            }
        }
    }

    foreach ($pwrPlan in $Plans)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $pwrPlan = @{} + $pwrPlan

        if (not $pwrPlan.ContainsKey('Ensure'))
        {
            $pwrPlan.Ensure = 'Present'
        }

        $executionName = "pwrplan_$($pwrPlan.GUID -replace '[{}\-\s]','')"

        (Get-DscSplattedResource -ResourceName cPowerPlan -ExecutionName $executionName -Properties $pwrPlan -NoInvoke).Invoke($pwrPlan)
    }

    foreach ($pwrSetting in $Settings)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $pwrSetting = @{} + $pwrSetting

        $executionName = "pwrsetting_$($pwrSetting.PlanGuid -replace '[{}\-\s]','')_$($pwrSetting.SettingGuid -replace '[{}\-\s]','')"

        (Get-DscSplattedResource -ResourceName cPowerPlanSetting -ExecutionName $executionName -Properties $pwrSetting -NoInvoke).Invoke($pwrSetting)
    }
}
