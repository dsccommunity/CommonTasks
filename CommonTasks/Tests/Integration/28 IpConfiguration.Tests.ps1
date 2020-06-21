Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

Describe "IpConfiguration DSC Resource compiles" -Tags FunctionalQuality {

    It "IpConfiguration Compiles" {
        
        configuration "Config_IpConfiguration" {

            Import-DscResource -ModuleName CommonTasks

            node "localhost_IpConfiguration" {
                IpConfiguration ipc {
                    Adapter = $configurationData.Datum.Config.IpConfiguration.Adapter
                 }
            }
        }

        { & "Config_IpConfiguration" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It "IpConfiguration should have created a mof file" {
        $mofFile = Get-Item -Path "$env:BHBuildOutput\localhost_IpConfiguration.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}
