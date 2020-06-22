Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AdDomainUsers DSC Resource compiles" -Tags FunctionalQuality {

    It "AdDomainUsers Compiles" {
        
        configuration "Config_AdDomainUsers" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AdDomainUsers" {
                AdDomainUsers adDomainUsers {
                    Users = $configurationData.Datum.Config.AdDomainUsers.Users
                }
            }
        }

        { & "Config_AdDomainUsers" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AdDomainUsers should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AdDomainUsers.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
