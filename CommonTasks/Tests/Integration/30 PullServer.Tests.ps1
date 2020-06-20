$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "PullServer DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "PullServer Compiles" {
        configuration "Config_PullServer" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_PullServer" {
                PullServer pulley { }
            }
        }

        { & "Config_PullServer" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "PullServer should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_PullServer.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
