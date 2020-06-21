Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "OrgUnitsAndGroups DSC Resource compiles" -Tags FunctionalQuality {

    It "OrgUnitsAndGroups Compiles" {

        configuration "Config_OrgUnitsAndGroups" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_OrgUnitsAndGroups" {
                OrgUnitsAndGroups orc {
                    Items = $configurationData.Datum.Config.OrgUnitsAndGroups.Items
                    Groups = $configurationData.Datum.Config.OrgUnitsAndGroups.Groups
                }
            }
        }

        { & "Config_OrgUnitsAndGroups" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "OrgUnitsAndGroups should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_OrgUnitsAndGroups.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
