Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "PullServer DSC Resource compiles" -Tags FunctionalQuality {

    It "PullServer Compiles" {

        configuration "Config_PullServer" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_PullServer" {
                PullServer pull { }
            }
        }

        { & "Config_PullServer" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "PullServer should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_PullServer.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
