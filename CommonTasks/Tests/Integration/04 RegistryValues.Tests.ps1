Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'RegistryValues DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'RegistryValues Compiles' {
        configuration Config_RegistryValues {

            Import-DscResource -ModuleName CommonTasks

            node localhost_RegistryValues {
                RegistryValues registryValues {
                    Values = $configurationData.Datum.Config.RegistryValues.Values
                }
            }
        }

        { Config_RegistryValues -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'RegistryValues should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_RegistryValues.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}