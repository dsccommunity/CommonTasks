Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'ChocolateyPackages DSC Resource compiles' -Tags FunctionalQuality {

    It 'ChocolateyPackages Compiles' {

        configuration Config_ChocolateyPackages {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ChocolateyPackages {
                ChocolateyPackages ChocolateyPackages {
                    Software = $configurationData.Datum.Config.ChocolateyPackages.Software
                    Sources = $configurationData.Datum.Config.ChocolateyPackages.Sources
                    Packages = $configurationData.Datum.Config.ChocolateyPackages.Packages
                }
            }
        }

        { Config_ChocolateyPackages -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ChocolateyPackages should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ChocolateyPackages.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
