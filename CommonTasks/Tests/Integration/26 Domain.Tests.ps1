Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "Domain DSC Resource compiles" -Tags FunctionalQuality {

    It "Domain Compiles" {

        configuration "Config_Domain" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_Domain" {
                Domain domain {
                    DomainFqdn = $configurationData.Datum.Config.Domain.DomainFqdn
                    DomainName = $configurationData.Datum.Config.Domain.DomainName
                    DomainDN = $configurationData.Datum.Config.Domain.DomainDN
                    DomainJoinAccount = $configurationData.Datum.Config.Domain.DomainJoinAccount
                    DomainAdministrator = $configurationData.Datum.Config.Domain.DomainAdministrator
                    SafeModePassword = $configurationData.Datum.Config.Domain.SafeModePassword
                    DomainTrust = $configurationData.Datum.Config.Domain.DomainTrust
                }
            }
        }

        { & "Config_Domain" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "Domain should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_Domain.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
