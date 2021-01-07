Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'Disks DSC Resource compiles' -Tags FunctionalQuality {
    
    It 'Disks Compiles' {

        configuration Config_Disks {

            Import-DscResource -ModuleName CommonTasks

            node localhost_Disks {
                Disks disks {
                    Disks = $configurationData.Datum.Config.Disks.Disks
                }
            }
        }

        { Config_Disks -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'Disks should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_Disks.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
