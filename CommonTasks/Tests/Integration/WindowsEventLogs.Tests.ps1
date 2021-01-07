Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "WindowsEventLogs DSC Resource compiles" -Tags FunctionalQuality {

    It "WindowsEventLogs Compiles" {

        configuration "Config_WindowsEventLogs" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_WindowsEventLogs" {
                WindowsEventLogs eventLogs {
                    Logs = $configurationData.Datum.Config.WindowsEventLogs.Logs
                }
            }
        }

        { & "Config_WindowsEventLogs" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "WindowsEventLogs should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_WindowsEventLogs.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
