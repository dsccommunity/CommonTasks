Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'SecurityPolicies DSC Resource compiles' -Tags FunctionalQuality {

    It 'SecurityPolicies Compiles' {

        configuration Config_SecurityPolicies {

            Import-DscResource -ModuleName CommonTasks

            node localhost_SecurityPolicies {
                SecurityPolicies policies {
                    AccountPolicies       = $configurationData.Datum.Config.SecurityPolicies.AccountPolicies
                    SecurityOptions       = $configurationData.Datum.Config.SecurityPolicies.SecurityOptions
                    UserRightsAssignments = $configurationData.Datum.Config.SecurityPolicies.UserRightsAssignments
                    SecurityTemplatePath  = $configurationData.Datum.Config.SecurityPolicies.SecurityTemplatePath
                }
            }
        }

        { Config_SecurityPolicies -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SecurityPolicies should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SecurityPolicies.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
