BeforeDiscovery {
    $dscResources = Get-DscResource -Module $moduleUnderTest.Name
    $here = $PSScriptRoot

    $skippedDscResources = 'PowerShellRepositories'

    Import-Module -Name datum

    $datum = New-DatumStructure -DefinitionFile $here\Assets\Datum.yml
    $allNodes = Get-Content -Path $here\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

    Write-Build DarkGray 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
    Initialize-DscResourceMetaInfo -ModulePath $RequiredModulesDirectory
    Write-Build DarkGray 'Done'

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

}

Describe 'DSC Composite Resources compile' -Tags FunctionalQuality {

    It "'<DscResourceName>' compiles"-TestCases $testCases {

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

        $dscConfiguration = $dscConfiguration.Replace("#<importStatements>", "Import-DscResource -Module $($moduleUnderTest.Name)")
        Invoke-Expression -Command $dscConfiguration

        {
            & "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $OutputDirectory -ErrorAction Stop
        } | Should -Not -Throw
    }

    It "'<DscResourceName>' should have created a mof file" -TestCases $testCases {
        if ($DscResourceName -in $skippedDscResources)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        $mofFile = Get-Item -Path "$($OutputDirectory)\localhost_$DscResourceName.mof" -ErrorAction SilentlyContinue
        $mofFile | Should -BeOfType System.IO.FileInfo
    }
}

Describe 'Final tests' -Tags FunctionalQuality {
    BeforeAll {
        $compositeResouces = Get-DscResource -Module DscConfig.Demo
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

        $compositeResouceFolders = dir -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*"
        Write-Host "Number of composite resource folders: $($compositeResouceFolders.Count)"
        $compositeResouceFolders = $compositeResouceFolders | Where-Object Name -NotIn $skippedDscResources
        Write-Host "Number of composite resource folders (considering 'skippedDscResources'): $($compositeResouceFolders.Count)"
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        Write-Host (Compare-Object -ReferenceObject $compositeResouceFolders.Name -DifferenceObject $compositeResouces.Name | Out-String) -ForegroundColor Yellow

        $compositeResouces.Count | Should -Be $compositeResouceFolders.Count

    }
}
