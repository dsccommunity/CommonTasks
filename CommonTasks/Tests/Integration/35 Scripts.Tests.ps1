Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'Scripts DSC Resource compiles' -Tags FunctionalQuality {

    It 'Scripts Compiles' {
        
        configuration Config_Scripts {

            Import-DscResource -ModuleName CommonTasks

            node localhost_Scripts {
                Scripts scripts {
                    Items = $configurationData.Datum.Config.Scripts.Items
                }
            }
        }

        { Config_Scripts -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'Scripts should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_Scripts.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
