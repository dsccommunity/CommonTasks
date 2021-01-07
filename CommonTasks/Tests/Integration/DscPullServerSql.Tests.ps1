Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DscPullServerSql DSC Resource compiles" -Tags FunctionalQuality {

    It "DscPullServerSql Compiles" {

        configuration "Config_DscPullServerSql" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DscPullServerSql" {
                DscPullServerSql pull {
                    CertificateThumbPrint = $configurationData.Datum.Config.DscPullServerSql.CertificateThumbPrint
                    Port = $configurationData.Datum.Config.DscPullServerSql.Port
                    RegistrationKey = $configurationData.Datum.Config.DscPullServerSql.RegistrationKey
                    SqlServer = $configurationData.Datum.Config.DscPullServerSql.SqlServer
                    DatabaseName = $configurationData.Datum.Config.DscPullServerSql.DatabaseName
                    EndpointName = $configurationData.Datum.Config.DscPullServerSql.EndpointName
                    PhysicalPath = $configurationData.Datum.Config.DscPullServerSql.PhysicalPath
                    ModulePath = $configurationData.Datum.Config.DscPullServerSql.ModulePath
                    ConfigurationPath = $configurationData.Datum.Config.DscPullServerSql.ConfigurationPath
                    UseSecurityBestPractices = $configurationData.Datum.Config.DscPullServerSql.UseSecurityBestPractices
                }
            }
        }

        { & "Config_DscPullServerSql" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DscPullServerSql should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DscPullServerSql.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
