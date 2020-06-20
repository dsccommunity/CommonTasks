$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebSites DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebSites Compiles' {
        configuration Config_WebSites {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebSites {
                WebSites applicationPool {
                    Items = $ConfigurationData.WebSites.Items
                }
            }
        }

        { Config_WebSites -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebSites should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebSites.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}