$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe "Wds DSC Resource compiles" -Tags 'FunctionalQuality' {
    It "Wds Compiles" {
        configuration "Config_Wds" {
            function Lookup {}
            Mock -CommandName Lookup -MockWith {'contoso.comdoesnotmatter'}

            Import-DscResource -ModuleName CommonTasks

            node "localhost_Wds" {
                Wds wds {
                    RemInstPath = $ConfigurationData.Wds.RemInstPath
                    RunAsUser = $ConfigurationData.Wds.RunAsUser
                    ScopeStart = $ConfigurationData.Wds.ScopeStart
                    ScopeEnd = $ConfigurationData.Wds.ScopeEnd
                    ScopeId = $ConfigurationData.Wds.ScopeId
                    SubnetMask = $ConfigurationData.Wds.SubnetMask
                 }
            }
        }

        { & "Config_Wds" -ConfigurationData $configData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "Wds should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_Wds.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
