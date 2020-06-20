$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "DomainUsers DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "DomainUsers Compiles" {
        function Lookup {}
        Mock -CommandName Lookup -MockWith {'contoso.comdoesnotmatter'}
        configuration "Config_DomainUsers" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DomainUsers" {
                DomainUsers domainUsers {
                    Users = $ConfigurationData.DomainUsers.Users
                }
            }
        }

        { & "Config_DomainUsers" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DomainUsers should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DomainUsers.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
