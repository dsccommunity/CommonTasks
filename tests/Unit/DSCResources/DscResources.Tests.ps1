$dscResources = Get-DscResource -Module CommonTasks2
$here = $PSScriptRoot
$skippedDscResources = 'ConfigurationManagerDeployment'

Import-Module -Name datum

$datum = New-DatumStructure -DefinitionFile $here\Assets\Datum.yml
$allNodes = Get-Content -Path $here\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

$global:configurationData = @{
    AllNodes = [array]$allNodes
    Datum    = $Datum
}

foreach ($dscResourceName in $dscResources.Name) {
    Describe "'$dscResourceName' DSC Resource compiles" -Tags FunctionalQuality {

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

        It "'$dscResourceName' compiles" {

            if ($dscResourceName -in $skippedDscResources) {
                Set-ItResult -Skipped -Because "Tests for '$dscResourceName' are skipped"
            }

            $nodeData = @{
                NodeName                    = "localhost_$dscResourceName"
                PSDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser        = $true
            }
            $configurationData.AllNodes += $nodeData

            configuration "Config_$dscResourceName" {

                Import-DscResource -ModuleName CommonTasks2

                node "localhost_$dscResourceName" {

                    $data = $configurationData.Datum.Config."$dscResourceName"
                    if (-not $data) {
                        $data = @{}
                    }
                    (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $dscResourceName -Properties $data -NoInvoke).Invoke($data)
                }
            }

            {
                & "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $OutputDirectory -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "'$dscResourceName' should have created a mof file" {
            if ($dscResourceName -in $skippedDscResources) {
                Set-ItResult -Skipped -Because "Tests for '$dscResourceName' are skipped"
            }

            $mofFile = Get-Item -Path "$($OutputDirectory)\localhost_$dscResourceName.mof" -ErrorAction SilentlyContinue
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

Describe 'Final tests' -Tags FunctionalQuality {
    BeforeAll {
        $compositeResouces = Get-DscResource -Module CommonTasks2
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        $compositeResouces = $compositeResouces | Where-Object Name -NotIn $skippedDscResources
        Write-Host "Number of composite resources (considering 'skippedDscResources'): $($compositeResouces.Count)"
    }

    It 'Every composite resource has compiled' {

        $mofFiles = Get-ChildItem -Path $OutputDirectory -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"
        $compositeResouces.Count | Should -Be $mofFiles.Count

    }

    It 'Composite resource folder count matches composite resource count' {

        $compositeResouceFolders = dir -Path "$OutputDirectory\Module\CommonTasks2\*\DSCResources\*"
        Write-Host "Number of composite resource folders: $($compositeResouceFolders.Count)"
        $compositeResouceFolders = $compositeResouceFolders | Where-Object Name -NotIn $skippedDscResources
        Write-Host "Number of composite resource folders (considering 'skippedDscResources'): $($compositeResouceFolders.Count)"
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        Write-Host (Compare-Object -ReferenceObject $compositeResouceFolders.Name -DifferenceObject $compositeResouces.Name | Out-String) -ForegroundColor Yellow

        $compositeResouces.Count | Should -Be $compositeResouceFolders.Count
    }
}
