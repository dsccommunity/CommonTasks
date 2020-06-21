Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe 'DscDiagnostic DSC Resource compiles' -Tags FunctionalQuality {

    It 'DscDiagnostic Compiles' {
        
        configuration Config_DscDiagnostic {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscDiagnostics {
                DscDiagnostic diagnostic { }
            }
        }

        { Config_DscDiagnostic -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscDiagnostics should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscDiagnostics.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
