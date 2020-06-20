$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'ConfigurationBase DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'ConfigurationBase Compiles' {
        configuration Config_ConfigurationBase {

            Import-DscResource -ModuleName CommonTasks

            node localhost_ConfigurationBase {
                ConfigurationBase base {
                    SystemType = $ConfigurationData.ConfigurationBase.SystemType
                }
            }
        }

        { Config_ConfigurationBase -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'ConfigurationBase should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_ConfigurationBase.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}