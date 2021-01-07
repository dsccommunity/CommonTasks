Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsSitesSubnets DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsSitesSubnets Compiles" {

        configuration "Config_AddsSitesSubnets" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AddsSitesSubnets" {
                AddsSitesSubnets adsitesub {
                    Sites = $configurationData.Datum.Config.AddsSitesSubnets.Sites
                    Subnets = $configurationData.Datum.Config.AddsSitesSubnets.Subnets
                }
            }
        }

        { & "Config_AddsSitesSubnets" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsSitesSubnets should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsSitesSubnets.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
