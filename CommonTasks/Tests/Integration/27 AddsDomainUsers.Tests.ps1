Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsDomainUsers DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsDomainUsers Compiles" {
        
        configuration "Config_AddsDomainUsers" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AddsDomainUsers" {
                AddsDomainUsers AddsDomainUsers {
                    Users = $configurationData.Datum.Config.AddsDomainUsers.Users
                }
            }
        }

        { & "Config_AddsDomainUsers" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsDomainUsers should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsDomainUsers.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
