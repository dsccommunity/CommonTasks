Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'AuditPolicies DSC Resource compiles' -Tags FunctionalQuality {

    It 'AuditPolicies Compiles' {

        configuration Config_AuditPolicies {

            Import-DscResource -ModuleName CommonTasks

            node localhost_AuditPolicies {
                AuditPolicies policies {
                    Options         = $configurationData.Datum.Config.AuditPolicies.Options
                    Subcategories   = $configurationData.Datum.Config.AuditPolicies.Subcategories
                    Guids           = $configurationData.Datum.Config.AuditPolicies.Guids
                    CsvPath         = $configurationData.Datum.Config.AuditPolicies.CsvPath
                }
            }
        }

        { Config_AuditPolicies -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'AuditPolicies should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_AuditPolicies.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
