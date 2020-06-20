$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'ComputerSettings DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'ComputerSettings Compiles' {
        configuration Config_ComputerSettings {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ComputerSettings {
                ComputerSettings settings {
                    TimeZone = $ConfigurationData.ComputerSettings.TimeZone
                    Name = $ConfigurationData.ComputerSettings.Name
                    Description = $ConfigurationData.ComputerSettings.Description
                }
            }
        }

        { Config_ComputerSettings -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ComputerSettings should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ComputerSettings.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}