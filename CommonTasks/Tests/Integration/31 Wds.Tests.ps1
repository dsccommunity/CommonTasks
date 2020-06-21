Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "Wds DSC Resource compiles" -Tags FunctionalQuality {

    It "Wds Compiles" {

        configuration "Config_Wds" {
        
            Import-DscResource -ModuleName CommonTasks

            node "localhost_Wds" {
                Wds wds {
                    RemInstPath = $configurationData.Datum.Config.Wds.RemInstPath
                    RunAsUser = $configurationData.Datum.Config.Wds.RunAsUser
                    ScopeStart = $configurationData.Datum.Config.Wds.ScopeStart
                    ScopeEnd = $configurationData.Datum.Config.Wds.ScopeEnd
                    ScopeId = $configurationData.Datum.Config.Wds.ScopeId
                    SubnetMask = $configurationData.Datum.Config.Wds.SubnetMask
                 }
            }
        }

        { & "Config_Wds" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "Wds should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_Wds.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
