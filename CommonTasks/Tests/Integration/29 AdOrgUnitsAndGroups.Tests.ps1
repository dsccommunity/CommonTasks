Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AdOrgUnitsAndGroups DSC Resource compiles" -Tags FunctionalQuality {

    It "AdOrgUnitsAndGroups Compiles" {

        configuration "Config_AdOrgUnitsAndGroups" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AdOrgUnitsAndGroups" {
                AdOrgUnitsAndGroups orc {
                    OrgUnits = $configurationData.Datum.Config.AdOrgUnitsAndGroups.OrgUnits
                    Groups = $configurationData.Datum.Config.AdOrgUnitsAndGroups.Groups
                }
            }
        }

        { & "Config_AdOrgUnitsAndGroups" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AdOrgUnitsAndGroups should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AdOrgUnitsAndGroups.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
