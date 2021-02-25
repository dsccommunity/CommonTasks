Import-Module -Name $PSScriptRoot\Assets\TestHelpers.psm1

$dscResources = Get-DscResource -Module CommonTasks
Init

foreach ($dscResourceName in $dscResources.Name) {
    Describe "'$DscResourceName' DSC Resource compiles" -Tags FunctionalQuality {

        BeforeAll {
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
        }

        It "'$DscResourceName' compiles" {
            
            $nodeData = @{
                NodeName = "localhost_$DscResourceName"
                PSDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser = $true
            }
            $configurationData.AllNodes += $nodeData

            configuration "Config_$DscResourceName" {

                Import-DscResource -ModuleName CommonTasks

                node "localhost_$DscResourceName" {

                    $data = $configurationData.Datum.Config."$DscResourceName"
                    if (-not $data) {
                        $data = @{}
                    }
                    (Get-DscSplattedResource -ResourceName $DscResourceName -ExecutionName $DscResourceName -Properties $data -NoInvoke).Invoke($data)
                }
            }

            { & "Config_$DscResourceName" -ConfigurationData $configurationData -OutputPath $env:BHBuildOutput -ErrorAction Stop } | Should -Not -Throw
        }

        It "'$DscResourceName' should have created a mof file" {
            $mofFile = Get-Item -Path "$($env:BHBuildOutput)\localhost_$DscResourceName.mof" -ErrorAction SilentlyContinue
            $mofFile | Should -BeOfType System.IO.FileInfo
        }

        AfterAll {
            Remove-Item -Path C:\Temp\JeaRoleTest.ps1
            if (-not $tempExists) {
                Remove-Item -Path C:\Temp
            }
        }
    }
}
