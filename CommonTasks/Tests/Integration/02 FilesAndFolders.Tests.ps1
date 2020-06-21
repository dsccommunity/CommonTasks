Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'FilesAndFolders DSC Resource compiles' -Tags FunctionalQuality {

    It 'FilesAndFolders Compiles' {
        
        configuration Config_FilesAndFolders {

            Import-DscResource -ModuleName CommonTasks

            node localhost_FilesAndFolders {
                FilesAndFolders filesAndFolders {
                    Items = $configurationData.Datum.Config.FilesAndFolders.Items
                }
            }
        }

        { Config_FilesAndFolders -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FilesAndFolders should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FilesAndFolders.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
