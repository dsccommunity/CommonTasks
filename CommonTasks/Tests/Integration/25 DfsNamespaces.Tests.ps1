$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "DfsNamespaces DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "DfsNamespaces Compiles" {
        function Lookup {}
        Mock -CommandName Lookup -MockWith {'contoso.comdoesnotmatter'}
        configuration "Config_DfsNamespaces" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DfsNamespaces" {
                DfsNamespaces dfsn {
                    NamespaceConfig = $ConfigurationData.DfsNamespace.NamespaceConfig
                }
            }
        }

        { & "Config_DfsNamespaces" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DfsNamespaces should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DfsNamespaces.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
