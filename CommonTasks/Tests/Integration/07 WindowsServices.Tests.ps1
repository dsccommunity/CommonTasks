$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WindowsServices DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WindowsServices Compiles' {
        configuration Config_WindowsServices {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WindowsServices {
                WindowsServices windowsServices {
                    Services = $ConfigurationData.WindowsServices.Services
                }
            }
        }

        { Config_WindowsServices -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WindowsServices should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WindowsServices.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}