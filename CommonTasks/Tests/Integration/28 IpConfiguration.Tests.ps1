$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "IpConfiguration DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "IpConfiguration Compiles" {
        configuration "Config_IpConfiguration" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_IpConfiguration" {
                IpConfiguration ipc {
                    Adapter = $ConfigurationData.IpConfiguration.Adapter
                 }
            }
        }

        { & "Config_IpConfiguration" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "IpConfiguration should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_IpConfiguration.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
