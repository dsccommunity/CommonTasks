Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'SoftwarePackages DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'SoftwarePackages Compiles' {

        configuration Config_SoftwarePackages {

            Import-DscResource -ModuleName CommonTasks

            node localhost_SoftwarePackages {
                SoftwarePackages SoftwarePackages {
                    Packages = $configurationData.Datum.Config.SoftwarePackages.Packages
                }
            }
        }

        { Config_SoftwarePackages -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SoftwarePackages should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SoftwarePackages.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
