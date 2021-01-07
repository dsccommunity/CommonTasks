Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DnsServerSettings DSC Resource compiles" -Tags FunctionalQuality {

    It "DnsServerSettings Compiles" {

        configuration "Config_DnsServerSettings" {

            Import-DscResource -ModuleName CommonTasks

            $global:node = @{
                Name = 'localhost'
                NodeName = 'localhost'
            }

            node "localhost_DnsServerSettings" {
                DnsServerSettings dnsSettings {
                    Settings = $configurationData.Datum.Config.DnsServerSettings.Settings
                }
            }
        }

        { & "Config_DnsServerSettings" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DnsServerSettings should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DnsServerSettings.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
