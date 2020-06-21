Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'ConfigurationBase DSC Resource compiles' -Tags FunctionalQuality {

    It 'ConfigurationBase Compiles' {

        configuration Config_ConfigurationBase {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ConfigurationBase {
                ConfigurationBase base {
                    SystemType = $configurationData.Datum.Config.SecurityBase.SecurityLevel
                }
            }
        }

        { Config_ConfigurationBase -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ConfigurationBase should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ConfigurationBase.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
