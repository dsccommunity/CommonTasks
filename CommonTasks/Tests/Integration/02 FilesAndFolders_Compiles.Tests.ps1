$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'FilesAndFolders DSC Resource compiles' -Tags 'FunctionalQuality' {

    It 'FilesAndFolders Compiles' {
        configuration Config_FilesAndFolders {
    
            Import-DscResource -ModuleName CommonTasks
        
            node localhost_FilesAndFolders {
                FilesAndFolders filesAndFolders {
                    Items = $ConfigurationData.FilesAndFolders.Items
                }
            }
        }
        
        { Config_FilesAndFolders -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'FilesAndFolders should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_FilesAndFolders.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo        
    }
}