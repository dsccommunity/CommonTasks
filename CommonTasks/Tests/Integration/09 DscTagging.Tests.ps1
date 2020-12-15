Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'DscTagging DSC Resource compiles' -Tags FunctionalQuality {
    It 'DscTagging Compiles' {
        configuration Config_DscTagging {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscTagging {
                DscTagging tagging {
                    Version = (Get-Module -Name CommonTasks -ListAvailable).Version
                    Environment = $node.Environment
                    Layers = @( 'Layer1', 'Layer2', 'Layer3' )
                }
            }
        }

        { Config_DscTagging -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscTagging should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscTagging.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
