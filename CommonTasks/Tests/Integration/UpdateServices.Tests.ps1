Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'UpdateServices DSC Resource compiles' -Tags FunctionalQuality {

    It 'UpdateServices Compiles' {

        configuration Config_UpdateServices {

            Import-DscResource -ModuleName CommonTasks

            node localhost_UpdateServices {
                UpdateServices updSrv {
                    Server = $configurationData.Datum.Config.UpdateServices.Server
                    Cleanup = $configurationData.Datum.Config.UpdateServices.Cleanup
                    ApprovalRules = $configurationData.Datum.Config.UpdateServices.ApprovalRules
                }
            }
        }

        { Config_UpdateServices -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'UpdateServices should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_UpdateServices.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
