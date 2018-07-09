$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $ENV:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name  $ENV:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'SecurityBase DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'SecurityBase Compiles' {
        configuration Config_SecurityBase {

            Import-DscResource -ModuleName CommonTasks
        
            node localhost_SecurityBase {
                SecurityBase securityBase {
                    SecurityLevel = $ConfigurationData.SecurityBase.SecurityLevel
                }
            }
        }
        
        { Config_SecurityBase -ConfigurationData $configData -OutputPath $env:BHBuildOutput\ -ErrorAction Stop } | Should -Not -Throw
    }
}