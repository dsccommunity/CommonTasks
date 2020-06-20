$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'DscDiagnostic DSC Resource compiles' -Tags 'FunctionalQuality' {
    It 'DscDiagnostic Compiles' {
        configuration Config_DscDiagnostic {

            Import-DscResource -ModuleName CommonTasks

            node localhost_DscDiagnostics {
                DscDiagnostic diagnostic { }
            }
        }

        { Config_DscDiagnostic -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'DscDiagnostics should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_DscDiagnostics.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
