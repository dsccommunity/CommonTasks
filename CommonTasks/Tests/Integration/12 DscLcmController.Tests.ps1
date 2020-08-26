Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'DscLcmController DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'DscLcmController Compiles' {

        configuration Config_DscLcmController {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscLcmController {
                DscLcmController controller {
                    MaintenanceWindowMode       = $configurationData.Datum.Config.DscLcmController.MaintenanceWindowMode
                    MonitorInterval             = $configurationData.Datum.Config.DscLcmController.MonitorInterval
                    AutoCorrectInterval         = $configurationData.Datum.Config.DscLcmController.AutoCorrectInterval
                    AutoCorrectIntervalOverride = $configurationData.Datum.Config.DscLcmController.AutoCorrectIntervalOverride
                    RefreshInterval             = $configurationData.Datum.Config.DscLcmController.RefreshInterval
                    RefreshIntervalOverride     = $configurationData.Datum.Config.DscLcmController.RefreshIntervalOverride
                    ControllerInterval          = $configurationData.Datum.Config.DscLcmController.ControllerInterval
                    MaintenanceWindowOverride   = $configurationData.Datum.Config.DscLcmController.MaintenanceWindowOverride
                }
            }
        }

        { Config_DscLcmController -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscLcmController should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscLcmController.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
