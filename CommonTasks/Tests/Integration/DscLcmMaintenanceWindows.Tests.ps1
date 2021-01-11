Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'DscLcmMaintenanceWindows DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'DscLcmMaintenanceWindows Compiles' {

        configuration Config_DscLcmMaintenanceWindows {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscLcmMaintenanceWindows {
                DscLcmMaintenanceWindows controller {
                    MaintenanceWindows = $configurationData.Datum.Config.DscLcmMaintenanceWindows.MaintenanceWindows
                }
            }
        }

        { Config_DscLcmMaintenanceWindows -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscLcmMaintenanceWindows should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscLcmMaintenanceWindows.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
