Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AdDomain DSC Resource compiles" -Tags FunctionalQuality {

    It "AdDomain Compiles" {

        configuration "Config_AdDomain" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AdDomain" {
                AdDomain adDomain {
                    DomainFqdn = $configurationData.Datum.Config.AdDomain.DomainFqdn
                    DomainName = $configurationData.Datum.Config.AdDomain.DomainName
                    DomainDN = $configurationData.Datum.Config.AdDomain.DomainDN
                    DomainJoinAccount = $configurationData.Datum.Config.AdDomain.DomainJoinAccount
                    DomainAdministrator = $configurationData.Datum.Config.AdDomain.DomainAdministrator
                    SafeModePassword = $configurationData.Datum.Config.AdDomain.SafeModePassword
                    DomainTrust = $configurationData.Datum.Config.AdDomain.DomainTrust
                }
            }
        }

        { & "Config_AdDomain" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AdDomain should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AdDomain.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
