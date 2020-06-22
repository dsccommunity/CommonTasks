Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsDomain DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsDomain Compiles" {

        configuration "Config_AddsDomain" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AddsDomain" {
                AddsDomain AddsDomain {
                    DomainFqdn = $configurationData.Datum.Config.AddsDomain.DomainFqdn
                    DomainName = $configurationData.Datum.Config.AddsDomain.DomainName
                    DomainDN = $configurationData.Datum.Config.AddsDomain.DomainDN
                    DomainJoinAccount = $configurationData.Datum.Config.AddsDomain.DomainJoinAccount
                    DomainAdministrator = $configurationData.Datum.Config.AddsDomain.DomainAdministrator
                    SafeModePassword = $configurationData.Datum.Config.AddsDomain.SafeModePassword
                    DomainTrust = $configurationData.Datum.Config.AddsDomain.DomainTrust
                }
            }
        }

        { & "Config_AddsDomain" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsDomain should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsDomain.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
