$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebApplicationPool DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebApplicationPool Compiles' {
        configuration Config_WebApplicationPool {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebApplicationPool {
                WebApplicationPool applicationPool {
                    Items = $ConfigurationData.WebApplicationPools.Items
                }
            }
        }

        { Config_WebApplicationPool -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebApplicationPool should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebApplicationPool.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}