Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'FirewallRules DSC Resource compiles' -Tags FunctionalQuality {

    It 'FirewallRules Compiles' {

        configuration Config_FirewallRules {

            Import-DscResource -ModuleName CommonTasks

            node localhost_FirewallRules {
                FirewallRules FirewallRules {
                    Rules = $configurationData.Datum.Config.FirewallRules.Rules
                }
            }
        }

        { Config_FirewallRules -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FirewallRules should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FirewallRules.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
