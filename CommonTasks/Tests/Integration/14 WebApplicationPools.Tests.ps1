$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebApplicationPools DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebApplicationPools Compiles' {
        configuration Config_WebApplicationPools {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebApplicationPools {
                WebApplicationPools applicationPool {
                    Items = $ConfigurationData.WebApplicationPools.Items
                }
            }
        }

        { Config_WebApplicationPools -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebApplicationPools should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebApplicationPools.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}