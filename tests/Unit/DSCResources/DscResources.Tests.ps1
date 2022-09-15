BeforeDiscovery {
    $dscResources = Get-DscResource -Module $moduleUnderTest.Name
    $here = $PSScriptRoot

    $skippedDscResources = ''

    Import-Module -Name datum

    $datum = New-DatumStructure -DefinitionFile $here\Assets\Datum.yml
    $allNodes = Get-Content -Path $here\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

    Write-Host 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
    Initialize-DscResourceMetaInfo -ModulePath $RequiredModulesDirectory
    Write-Host 'Done'

    $global:configurationData = @{
        AllNodes = [array]$allNodes
        Datum    = $Datum
    }

    [hashtable[]]$testCases = @()
    foreach ($dscResource in $dscResources)
    {
        [PSCustomObject]$dscResourceModuleTable = @()
        $testCases += @{
            DscResourceName = $dscResource.Name
            Skip            = ($dscResource.Name -in $skippedDscResources)
        }
    }

    $compositeResources = Get-DscResource -Module $moduleUnderTest.Name
    $finalTestCases = @()
    $finalTestCases += @{
        AllCompositeResources            = $compositeResources.Name
        FilteredCompositeResources       = $compositeResources | Where-Object Name -NotIn $skippedDscResources
        AllCompositeResourceFolders      = dir -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*"
        FilteredCompositeResourceFolders = dir -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*" | Where-Object BaseName -NotIn $skippedDscResources
    }
}

Describe 'DSC Composite Resources compile' -Tags FunctionalQuality {
    BeforeAll {
        $tempExists = Test-Path -Path C:\Temp
        if (-not $tempExists)
        {
            New-Item -Path C:\Temp -ItemType Directory | Out-Null
        }
        @'
function f1 {
Get-Date
}
f1
'@ | Set-Content -Path C:\Temp\JeaRoleTest.ps1 -Force
    }

    It "'<DscResourceName>' compiles" -TestCases $testCases {

        if ($Skip)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        $nodeData = @{
            NodeName                    = "localhost_$dscResourceName"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
        }
        $configurationData.AllNodes = @($nodeData)

        $dscConfiguration = @'
configuration "Config_$dscResourceName" {

    #<importStatements>

    node "localhost_$dscResourceName" {

        $data = $configurationData.Datum.Config."$dscResourceName"
        if (-not $data)
        {
            $data = @{}
        }

        (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $dscResourceName -Properties $data -NoInvoke).Invoke($data)
    }
}
'@

        $dscConfiguration = $dscConfiguration.Replace('#<importStatements>', "Import-DscResource -Module $($moduleUnderTest.Name)")
        Invoke-Expression -Command $dscConfiguration

        {
            & "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $OutputDirectory -ErrorAction Stop
        } | Should -Not -Throw
    }

    It "'<DscResourceName>' should have created a mof file" -TestCases $testCases {

        if ($Skip)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        $mofFile = Get-Item -Path "$($OutputDirectory)\localhost_$DscResourceName.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }

    AfterAll {
        Remove-Item -Path C:\Temp\JeaRoleTest.ps1
        if (-not $tempExists)
        {
            Remove-Item -Path C:\Temp
        }
    }
}

Describe 'Final tests' -Tags FunctionalQuality {

    It 'Every composite resource has compiled' -TestCases $finalTestCases {

        $mofFiles = Get-ChildItem -Path $OutputDirectory -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"
        $FilteredCompositeResources.Count | Should -Be $mofFiles.Count

    }

    It 'Composite resource folder count matches composite resource count' -TestCases $finalTestCases {

        Write-Host "Number of composite resource folders: $($AllCompositeResourceFolders.Count)"
        Write-Host "Number of composite resource folders (considering 'skippedDscResources'): $($FilteredCompositeResourceFolders.Count)"
        Write-Host "Number of all composite resources: $($AllCompositeResources.Count)"
        Write-Host "Number of composite resources (considering 'skippedDscResources'): $($FilteredCompositeResources.Count)"

        Write-Host (Compare-Object -ReferenceObject $FilteredCompositeResourceFolders.BaseName -DifferenceObject $FilteredCompositeResources.Name | Out-String) -ForegroundColor Yellow

        $FilteredCompositeResourceFolders.Count | Should -Be $FilteredCompositeResources.Count

    }
}
