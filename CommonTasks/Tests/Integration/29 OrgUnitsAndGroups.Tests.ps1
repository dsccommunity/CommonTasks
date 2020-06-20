$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "OrgUnitsAndGroups DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "OrgUnitsAndGroups Compiles" {
        function Lookup {}
        Mock -CommandName Lookup -MockWith {'contoso.comdoesnotmatter'}
        configuration "Config_OrgUnitsAndGroups" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_OrgUnitsAndGroups" {
                OrgUnitsAndGroups orc {
                    Items = $ConfigurationData.OrgUnitsAndGroups.Items
                    Groups = $ConfigurationData.OrgUnitsAndGroups.Groups
                }
            }
        }

        { & "Config_OrgUnitsAndGroups" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "OrgUnitsAndGroups should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_OrgUnitsAndGroups.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
