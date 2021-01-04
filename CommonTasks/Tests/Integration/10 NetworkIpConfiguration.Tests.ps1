Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'NetworkIpConfiguration DSC Resource compiles' -Tags FunctionalQuality {

    It 'NetworkIpConfiguration Compiles' {

        configuration Config_NetworkIpConfiguration {

            Import-DscResource -ModuleName CommonTasks

            node localhost_NetworkIpConfiguration {
                NetworkIpConfiguration ipConfiguration {
                    Interfaces = $configurationData.Datum.Config.NetworkIpConfiguration.Interfaces
                }
            }
        }

        { Config_NetworkIpConfiguration -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'NetworkIpConfiguration should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_NetworkIpConfiguration.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
