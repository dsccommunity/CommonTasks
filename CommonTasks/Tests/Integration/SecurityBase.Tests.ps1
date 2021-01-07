Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'SecurityBase DSC Resource compiles' -Tags FunctionalQuality {

    It 'SecurityBase Compiles' {

        configuration Config_SecurityBase {

            Import-DscResource -ModuleName CommonTasks

            node localhost_SecurityBase {
                SecurityBase securityBase {
                    Role = $configurationData.Datum.Config.SecurityBase.SecurityLevel
                }
            }
        }

        { Config_SecurityBase  -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SecurityBase should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SecurityBase.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
