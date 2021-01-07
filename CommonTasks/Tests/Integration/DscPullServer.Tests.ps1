Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DscPullServer DSC Resource compiles" -Tags FunctionalQuality {

    It "DscPullServer Compiles" {

        configuration "Config_DscPullServer" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DscPullServer" {
                DscPullServer pull { }
            }
        }

        { & "Config_DscPullServer" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DscPullServer should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DscPullServer.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
