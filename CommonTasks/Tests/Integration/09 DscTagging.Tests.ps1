$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'DscTagging DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'DscTagging Compiles' {
        configuration Config_DscTagging {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscTagging {
                DscTagging tagging {
                    Version = (Get-Module -Name CommonTasks).Version
                    Environment = $node.Environment
                }
            }
        }

        { Config_DscTagging -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscTagging should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscTagging.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
