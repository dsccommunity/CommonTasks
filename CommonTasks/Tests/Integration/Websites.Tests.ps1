Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WebSites DSC Resource compiles' -Tags FunctionalQuality {

    It 'WebSites Compiles' {

        configuration Config_WebSites {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebSites {
                WebSites applicationPool {
                    Items = $configurationData.Datum.Config.WebSites.Items
                }
            }
        }

        { Config_WebSites -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebSites should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebSites.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
