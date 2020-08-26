Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "AddsOrgUnitsAndGroups DSC Resource compiles" -Tags FunctionalQuality {

    It "AddsOrgUnitsAndGroups Compiles" {

        configuration "Config_AddsOrgUnitsAndGroups" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_AddsOrgUnitsAndGroups" {
                AddsOrgUnitsAndGroups orc {
                    OrgUnits = $configurationData.Datum.Config.AddsOrgUnitsAndGroups.OrgUnits
                    Groups = $configurationData.Datum.Config.AddsOrgUnitsAndGroups.Groups
                }
            }
        }

        { & "Config_AddsOrgUnitsAndGroups" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "AddsOrgUnitsAndGroups should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_AddsOrgUnitsAndGroups.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
