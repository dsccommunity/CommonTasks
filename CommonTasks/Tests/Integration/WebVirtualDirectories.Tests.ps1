Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'WebVirtualDirectories DSC Resource compiles' -Tags FunctionalQuality {

    It 'WebVirtualDirectories Compiles' {

        configuration Config_WebVirtualDirectories {

            Import-DscResource -ModuleName CommonTasks

            node localhost_WebVirtualDirectories {
                WebVirtualDirectories virtualDirectory {
                    Items = $configurationData.Datum.Config.WebVirtualDirectories.Items
                }
            }
        }

        { Config_WebVirtualDirectories -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'WebVirtualDirectories should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_WebVirtualDirectories.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}