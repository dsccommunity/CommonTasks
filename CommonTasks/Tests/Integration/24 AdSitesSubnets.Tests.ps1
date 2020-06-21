Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AdSitesSubnets DSC Resource compiles" -Tags FunctionalQuality {

    It "AdSitesSubnets Compiles" {

        configuration "Config_AdSitesSubnets" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AdSitesSubnets" {
                AdSitesSubnets adsitesub {
                    Sites = $configurationData.Datum.Config.AdSitesSubnets.Sites
                    Subnets = $configurationData.Datum.Config.AdSitesSubnets.Subnets
                }
            }
        }

        { & "Config_AdSitesSubnets" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AdSitesSubnets should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AdSitesSubnets.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
