$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name  $env:BHProjectName -ErrorAction Stop

Import-Module -Name Datum

Describe 'Networking DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'Networking Compiles' {
        configuration Config_Network {

            Import-DscResource -ModuleName CommonTasks
        
            node localhost_Network {
                Network network {
                    NetworkZone = 1
                    MtuSize = 1360
                    DnsServer = '1.1.1.1', '2.2.2.2'
                }
            }
        }
        
        { Config_Network -ConfigurationData $configData -OutputPath $env:BHBuildOutput\ -ErrorAction Stop } | Should -Not -Throw
    }
}