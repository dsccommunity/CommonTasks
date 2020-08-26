Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WindowsServices DSC Resource compiles' -Tags FunctionalQuality {

    It 'WindowsServices Compiles' {

        configuration Config_WindowsServices {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WindowsServices {
                WindowsServices windowsServices {
                    Services = $configurationData.Datum.Config.WindowsServices.Services
                }
            }
        }

        { Config_WindowsServices -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WindowsServices should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WindowsServices.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
