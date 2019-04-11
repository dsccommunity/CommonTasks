$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'Website DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'Website Compiles' {
        configuration Config_Website {

            Import-DscResource -ModuleName CommonTasks

            node localhost_Website {
                Website applicationPool {
                    Items = $ConfigurationData.Websites.Items
                }
            }
        }

        { Config_Website -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'Website should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_Website.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}