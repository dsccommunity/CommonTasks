$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $ENV:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name  $ENV:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'WindowsFeatures DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WindowsFeatures Compiles' {
        configuration Config_WindowsFeatures {

            Import-DscResource -ModuleName CommonTasks
        
            node localhost_WindowsFeatures {
                WindowsFeatures windowsFeatures {
                    Name = $ConfigurationData.WindowsFeatures.Name
                }
            }
        }
        
        { Config_WindowsFeatures -ConfigurationData $configData -OutputPath $env:BHBuildOutput\ -ErrorAction Stop } | Should -Not -Throw
    }
}