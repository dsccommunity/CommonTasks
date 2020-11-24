Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DnsServerRootHints DSC Resource compiles" -Tags FunctionalQuality {

    It "DnsServerRootHints Compiles" {

        configuration "Config_DnsServerRootHints" {

            Import-DscResource -ModuleName CommonTasks

            $global:node = @{
                Name = 'localhost'
                NodeName = 'localhost'
            }

            node "localhost_DnsServerRootHints" {
                DnsServerRootHints rootHints {
                    RootHints = $configurationData.Datum.Config.DnsServerRootHints.RootHints
                }
            }
        }

        { & "Config_DnsServerRootHints" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DnsServerRootHints should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DnsServerRootHints.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
