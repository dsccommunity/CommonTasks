Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'EnvironmentVariables DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'EnvironmentVariables Compiles' {

        configuration Config_EnvironmentVariables {

            Import-DscResource -ModuleName CommonTasks

            node localhost_EnvironmentVariables {
                EnvironmentVariables variables {
                    Variables = $configurationData.Datum.Config.EnvironmentVariables.Variables
                }
            }
        }

        { Config_EnvironmentVariables -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'EnvironmentVariables should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_EnvironmentVariables.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
