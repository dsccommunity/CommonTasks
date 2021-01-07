Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WindowsFeatures DSC Resource compiles' -Tags FunctionalQuality {

    It 'WindowsFeatures Compiles' {
        
        configuration Config_WindowsFeatures {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WindowsFeatures {
                WindowsFeatures windowsFeatures {
                    Name = $configurationData.Datum.Config.WindowsFeatures.Name
                }
            }
        }

        { Config_WindowsFeatures -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WindowsFeatures should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WindowsFeatures.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}