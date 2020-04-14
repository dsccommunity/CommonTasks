$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'SoftwarePackages DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'SoftwarePackages Compiles' {
        configuration Config_SoftwarePackages {

            Import-DscResource -ModuleName CommonTasks

            node localhost_SoftwarePackages {
                SoftwarePackages SoftwarePackages {
                    Package = $ConfigurationData.SoftwarePackages.Packages
                }
            }
        }

        { Config_SoftwarePackages -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SoftwarePackages should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SoftwarePackages.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
