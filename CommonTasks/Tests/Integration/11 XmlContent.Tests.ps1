Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'XmlContent DSC Resource compiles' -Tags FunctionalQuality {

    It 'XmlContent Compiles' {

        configuration Config_XmlContent {

            Import-DscResource -ModuleName CommonTasks

            node localhost_XmlContent {
                XmlContent xml {
                    XmlData = $configurationData.Datum.Config.XmlData
                }
            }
        }

        { Config_XmlContent -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'XmlContent should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_XmlContent.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
