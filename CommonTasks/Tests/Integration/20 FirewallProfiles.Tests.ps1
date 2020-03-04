$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'FirewallProfiles DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'FirewallProfiles Compiles' {
        configuration Config_FirewallProfiles {

            Import-DscResource -ModuleName CommonTasks

            node localhost_FirewallProfiles {
                FirewallProfiles settings {
                    Profile = $ConfigurationData.FirewallProfiles.Profile
                }
            }
        }

        { Config_FirewallProfiles -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FirewallProfiles should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FirewallProfiles.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
