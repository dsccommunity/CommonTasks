$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'NetworkIpConfiguration DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'NetworkIpConfiguration Compiles' {
        configuration Config_NetworkIpConfiguration {

            Import-DscResource -ModuleName CommonTasks

            node localhost_NetworkIpConfiguration {
                NetworkIpConfiguration ipConfiguration {
                    IpAddress      = $ConfigurationData.NetworkIpConfiguration.IpAddress
                    Prefix         = $ConfigurationData.NetworkIpConfiguration.Prefix
                    Gateway        = $ConfigurationData.NetworkIpConfiguration.Gateway
                    DnsServer      = $ConfigurationData.NetworkIpConfiguration.DnsServer
                    InterfaceAlias = $ConfigurationData.NetworkIpConfiguration.InterfaceAlias
                    DisableNetbios = $ConfigurationData.NetworkIpConfiguration.DisableNetbios
                }
            }
        }

        { Config_NetworkIpConfiguration -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'NetworkIpConfiguration should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_NetworkIpConfiguration.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}