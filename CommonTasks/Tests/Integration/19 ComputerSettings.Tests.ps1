Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'ComputerSettings DSC Resource compiles' -Tags FunctionalQuality {

    It 'ComputerSettings Compiles' {

        configuration Config_ComputerSettings {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ComputerSettings {
                ComputerSettings settings {
                    TimeZone = $configurationData.Datum.Config.ComputerSettings.TimeZone
                    Name = $configurationData.Datum.Config.ComputerSettings.Name
                    Description = $configurationData.Datum.Config.ComputerSettings.Description
                }
            }
        }

        { Config_ComputerSettings -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ComputerSettings should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ComputerSettings.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
