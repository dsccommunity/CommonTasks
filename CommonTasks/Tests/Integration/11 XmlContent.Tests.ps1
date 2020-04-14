$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'XmlContent DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'XmlContent Compiles' {
        configuration Config_XmlContent {

            Import-DscResource -ModuleName CommonTasks

            node localhost_XmlContent {
                XmlContent xml {
                    XmlData = $ConfigurationData.XmlData
                }
            }
        }

        { Config_XmlContent -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'XmlContent should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_XmlContent.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
