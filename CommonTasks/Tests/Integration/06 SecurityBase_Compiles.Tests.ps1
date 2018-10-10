$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name  $env:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'SecurityBase DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'SecurityBase Compiles' {
        configuration Config_SecurityBase {

            Import-DscResource -ModuleName CommonTasks
        
            node localhost_SecurityBase {
                SecurityBase securityBase {
                    Role = 'SqlServer'
                }
            }
        }
        
        { Config_SecurityBase -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'SecurityBase should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_SecurityBase.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo        
    }
}