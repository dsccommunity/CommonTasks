Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'RegistryPolicies DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'RegistryPolicies Compiles' {
        configuration Config_RegistryPolicies {

            Import-DscResource -ModuleName CommonTasks

            node localhost_RegistryPolicies {
                RegistryPolicies registryPolicies {
                    Values = $configurationData.Datum.Config.RegistryPolicies.Values
                    GpUpdateInterval = $configurationData.Datum.Config.RegistryPolicies.GpUpdateInterval
                }
            }
        }

        { Config_RegistryPolicies -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'RegistryPolicies should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_RegistryPolicies.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}