$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'DscLcmController DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'DscLcmController Compiles' {
        configuration Config_DscLcmController {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscLcmController {
                DscLcmController controller {
                    ConsistencyCheckInterval         = $ConfigurationData.DscLcmController.ConsistencyCheckInterval
                    ConsistencyCheckIntervalOverride = $ConfigurationData.DscLcmController.ConsistencyCheckIntervalOverride
                    RefreshInterval                  = $ConfigurationData.DscLcmController.RefreshInterval
                    RefreshIntervalOverride          = $ConfigurationData.DscLcmController.RefreshIntervalOverride
                    ControllerInterval               = $ConfigurationData.DscLcmController.ControllerInterval
                    MaintenanceWindowOverride        = $ConfigurationData.DscLcmController.MaintenanceWindowOverride
                }
            }
        }

        { Config_DscLcmController -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscLcmController should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscLcmController.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}