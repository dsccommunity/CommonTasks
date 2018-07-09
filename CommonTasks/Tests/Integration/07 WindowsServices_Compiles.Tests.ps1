$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $ENV:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name  $ENV:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'WindowsServices DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'WindowsServices Compiles' {
        configuration Config_WindowsServices {

            Import-DscResource -ModuleName CommonTasks
        
            node localhost_WindowsServices {
                WindowsServices windowsServices {
                    Services = $ConfigurationData.WindowsServices.Services
                }
            }
        }
        
        { Config_WindowsServices -ConfigurationData $configData -OutputPath $env:BHBuildOutput\ -ErrorAction Stop } | Should -Not -Throw
    }
}