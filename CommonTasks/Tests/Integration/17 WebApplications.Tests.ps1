Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WebApplications DSC Resource compiles' -Tags FunctionalQuality {

    It 'WebApplications Compiles' {

        configuration Config_WebApplications {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebApplications {
                WebApplications application {
                    Items = $configurationData.Datum.Config.WebApplications.Items
                }
            }
        }

        { Config_WebApplications -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebApplications should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebApplications.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
