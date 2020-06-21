Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DomainUsers DSC Resource compiles" -Tags FunctionalQuality {

    It "DomainUsers Compiles" {
        
        configuration "Config_DomainUsers" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DomainUsers" {
                DomainUsers domainUsers {
                    Users = $configurationData.Datum.Config.DomainUsers.Users
                }
            }
        }

        { & "Config_DomainUsers" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DomainUsers should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DomainUsers.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
