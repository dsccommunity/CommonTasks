$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebVirtualDirectory DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebVirtualDirectory Compiles' {
        configuration Config_WebVirtualDirectory {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebVirtualDirectory {
                WebVirtualDirectory applicationPool {
                    Items = $ConfigurationData.WebVirtualDirectories.Items
                }
            }
        }

        { Config_WebVirtualDirectory -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebVirtualDirectory should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebVirtualDirectory.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}