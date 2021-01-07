Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsSiteLinks DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsSiteLinks Compiles" {
        
        configuration "Config_AddsSiteLinks" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AddsSiteLinks" {
                AddsSiteLinks AddsSiteLinks {
                    SiteLinks = $configurationData.Datum.Config.AddsSiteLinks.SiteLinks
                }
            }
        }

        { & "Config_AddsSiteLinks" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsSiteLinks should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsSiteLinks.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
