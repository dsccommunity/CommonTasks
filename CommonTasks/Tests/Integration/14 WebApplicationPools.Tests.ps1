Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WebApplicationPools DSC Resource compiles' -Tags FunctionalQuality {

    It 'WebApplicationPools Compiles' {

        configuration Config_WebApplicationPools {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebApplicationPools {
                WebApplicationPools applicationPool {
                    Items = $configurationData.Datum.Config.WebApplicationPools.Items
                }
            }
        }

        { Config_WebApplicationPools -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebApplicationPools should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebApplicationPools.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
