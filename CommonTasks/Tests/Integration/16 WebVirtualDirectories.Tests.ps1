$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebVirtualDirectories DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebVirtualDirectories Compiles' {
        configuration Config_WebVirtualDirectories {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebVirtualDirectories {
                WebVirtualDirectories virtualDirectory {
                    Items = $ConfigurationData.WebVirtualDirectories.Items
                }
            }
        }

        { Config_WebVirtualDirectories -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebVirtualDirectories should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebVirtualDirectories.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}