$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'WebApplications DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WebApplications Compiles' {
        configuration Config_WebApplications {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebApplications {
                WebApplications application {
                    Items = $ConfigurationData.WebApplications.Items
                }
            }
        }

        { Config_WebApplications -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebApplications should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebApplications.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
