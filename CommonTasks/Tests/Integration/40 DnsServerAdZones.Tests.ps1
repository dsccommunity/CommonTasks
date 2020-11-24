Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DnsServerAdZones DSC Resource compiles" -Tags FunctionalQuality {

    It "DnsServerAdZones Compiles" {

        configuration "Config_DnsServerAdZones" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DnsServerAdZones" {
                DnsServerAdZones adZones {
                    AdZones = $configurationData.Datum.Config.DnsServerAdZones.AdZones
                }
            }
        }

        { & "Config_DnsServerAdZones" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DnsServerAdZones should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DnsServerAdZones.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
