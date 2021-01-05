Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'SqlServer DSC Resource compiles' -Tags FunctionalQuality {

    It 'SqlServer Compiles' {

        configuration Config_SqlServer {

            Import-DscResource -ModuleName CommonTasks

            node localhost_SqlServer {
                SqlServer sqlSrv {
                    Setup = $configurationData.Datum.Config.SqlServer.Setup
                }
            }
        }

        { Config_SqlServer -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SqlServer should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SqlServer.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
