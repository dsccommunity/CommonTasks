Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "DfsNamespaces DSC Resource compiles" -Tags FunctionalQuality {

    It "DfsNamespaces Compiles" {

        configuration "Config_DfsNamespaces" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_DfsNamespaces" {
                DfsNamespaces dfsn {
                    NamespaceConfig = $configurationData.Datum.Config.DfsNamespace.NamespaceConfig
                }
            }
        }

        { & "Config_DfsNamespaces" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "DfsNamespaces should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_DfsNamespaces.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
