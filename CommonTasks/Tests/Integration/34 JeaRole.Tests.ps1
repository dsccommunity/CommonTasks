Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1
Init

$tempExists = Test-Path -Path C:\Temp
if (-not $tempExists) {
    New-Item -Path C:\Temp -ItemType Directory | Out-Null
}
@'
function f1 {
    Get-Date
}

f1
'@ | Set-Content -Path C:\Temp\JeaRoleTest.ps1 -Force

Describe 'JeaRoles DSC Resource compiles' -Tags FunctionalQuality {

    It 'JeaRoles Compiles' {

        configuration Config_JeaRoles {

            Import-DscResource -ModuleName CommonTasks

            node localhost_JeaRoles {
                JeaRoles JeaRoles {
                    Roles = $configurationData.Datum.Config.JeaRoles.Roles
                }
            }
        }

        { Config_JeaRoles -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
    }

    It 'JeaRoles should have created a mof file' {
        $mofFile = Get-Item -Path $env:BHBuildOutput\localhost_JeaRoles.mof -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}

Remove-Item -Path C:\Temp\JeaRoleTest.ps1
if (-not $tempExists) {
    Remove-Item -Path C:\Temp
}
