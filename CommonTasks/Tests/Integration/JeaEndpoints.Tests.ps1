Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'JeaEndpoints DSC Resource compiles' -Tags FunctionalQuality {

    It 'JeaEndpoints Compiles' {

        configuration Config_JeaEndpoints {

            Import-DscResource -ModuleName CommonTasks

            node localhost_JeaEndpoints {
                JeaEndpoints JeaEndpoints {
                    Endpoints = $configurationData.Datum.Config.JeaEndpoints.Endpoints
                }
            }
        }

        { Config_JeaEndpoints -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'JeaEndpoints should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_JeaEndpoints.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
