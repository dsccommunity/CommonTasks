$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'FirewallRules DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'FirewallRules Compiles' {
        configuration Config_FirewallRules {

            Import-DscResource -ModuleName CommonTasks

            node localhost_FirewallRules {
                FirewallRules FirewallRules {
                    Rules = $ConfigurationData.FirewallRules.Rules
                }
            }
        }

        { Config_FirewallRules -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FirewallRules should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FirewallRules.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
