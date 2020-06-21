Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'Network DSC Resource compiles' -Tags FunctionalQuality {

    It 'Network Compiles' {

        configuration Config_Network {

            Import-DscResource -ModuleName CommonTasks

            node localhost_Network {
                Network network {
                    NetworkZone = $configurationData.Datum.Config.Network.NetworkZone
                    MtuSize     = $configurationData.Datum.Config.Network.MtuSize
                }
            }
        }

        { Config_Network -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'Network should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_Network.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
