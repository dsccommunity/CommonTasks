Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DnsServerConditionalForwarders DSC Resource compiles" -Tags FunctionalQuality {

    It "DnsServerConditionalForwarders Compiles" {

        configuration "Config_DnsServerConditionalForwarders" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DnsServerConditionalForwarders" {
                DnsServerConditionalForwarders conditionalForwarders {
                    ConditionalForwarders = $configurationData.Datum.Config.DnsServerConditionalForwarders.ConditionalForwarders
                }
            }
        }

        { & "Config_DnsServerConditionalForwarders" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DnsServerConditionalForwarders should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DnsServerConditionalForwarders.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
