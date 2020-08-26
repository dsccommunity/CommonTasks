Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'FirewallProfiles DSC Resource compiles' -Tags FunctionalQuality {

    It 'FirewallProfiles Compiles' {

        configuration Config_FirewallProfiles {

            Import-DscResource -ModuleName CommonTasks

            node localhost_FirewallProfiles {
                FirewallProfiles settings {
                    Profile = $configurationData.Datum.Config.FirewallProfiles.Profile
                }
            }
        }

        { Config_FirewallProfiles -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FirewallProfiles should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FirewallProfiles.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
