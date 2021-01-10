Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'RestartSystem DSC Resource compiles' -Tags FunctionalQuality {

    It 'RestartSystem Compiles' {

        configuration Config_RestartSystem {

            Import-DscResource -ModuleName CommonTasks

            node localhost_RestartSystem {
                RestartSystem restartSys {
                    ForceReboot = $configurationData.Datum.Config.RestartSystem.ForceReboot
                    PendingReboot = $configurationData.Datum.Config.RestartSystem.PendingReboot
                    SkipComponentBasedServicing = $configurationData.Datum.Config.RestartSystem.SkipComponentBasedServicing
                    SkipWindowsUpdate = $configurationData.Datum.Config.RestartSystem.SkipWindowsUpdate
                    SkipPendingFileRename = $configurationData.Datum.Config.RestartSystem.SkipPendingFileRename
                    SkipPendingComputerRename = $configurationData.Datum.Config.RestartSystem.SkipPendingComputerRename
                    SkipCcmClientSDK = $configurationData.Datum.Config.RestartSystem.SkipCcmClientSDK
                }
            }
        }

        { Config_RestartSystem -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'RestartSystem should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_RestartSystem.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
