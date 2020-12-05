Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsDomainController DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsDomainController Compiles" {

        configuration "Config_AddsDomainController" {

            Import-DscResource –ModuleName PSDesiredStateConfiguration
            Import-DscResource -ModuleName CommonTasks

            node localhost_AddsDomainController {
                AddsDomainController dc {                    
                    DomainName = $configurationData.Datum.Config.AddsDomainController.DomainName
                    Credential = $configurationData.Datum.Config.AddsDomainController.Credential
                    SafeModeAdministratorPassword = $configurationData.Datum.Config.AddsDomainController.SafeModeAdministratorPassword
                    DatabasePath = $configurationData.Datum.Config.AddsDomainController.DatabasePath
                    LogPath = $configurationData.Datum.Config.AddsDomainController.LogPath
                    SysvolPath = $configurationData.Datum.Config.AddsDomainController.SysvolPath
                    SiteName = $configurationData.Datum.Config.AddsDomainController.SiteName
                    IsGlobalCatalog = $configurationData.Datum.Config.AddsDomainController.IsGlobalCatalog
                    InstallationMediaPath = $configurationData.Datum.Config.AddsDomainController.InstallationMediaPath
                }
            }
        }

        { & Config_AddsDomainController -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsDomainController should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsDomainController.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
