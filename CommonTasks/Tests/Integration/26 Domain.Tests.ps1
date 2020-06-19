$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "Domain DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "Domain Compiles" {

        configuration "Config_Domain" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_Domain" {
                Domain domain {
                    DomainFqdn = $ConfigurationData.Domain.DomainFqdn
                    DomainName = $ConfigurationData.Domain.DomainName
                    DomainDN = $ConfigurationData.Domain.DomainDN
                    DomainJoinAccount = $ConfigurationData.Domain.DomainJoinAccount
                    DomainAdministrator = $ConfigurationData.Domain.DomainAdministrator
                    SafeModePassword = $ConfigurationData.Domain.SafeModePassword
                    DomainTrust = $ConfigurationData.Domain.DomainTrust
                }
            }
        }

        { & "Config_Domain" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "Domain should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_Domain.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
