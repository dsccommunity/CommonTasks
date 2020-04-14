$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'DscLcmMaintenanceWindows DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'DscLcmMaintenanceWindows Compiles' {
        configuration Config_DscLcmMaintenanceWindows {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscLcmMaintenanceWindows {
                DscLcmMaintenanceWindows controller {
                    MaintenanceWindow = $ConfigurationData.DscLcmMaintenanceWindows.MaintenanceWindow
                }
            }
        }

        { Config_DscLcmMaintenanceWindows -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscLcmMaintenanceWindows should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscLcmMaintenanceWindows.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
