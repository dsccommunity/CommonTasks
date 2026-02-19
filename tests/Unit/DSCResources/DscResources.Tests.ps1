BeforeDiscovery {
    # Suppress benign errors from Get-DscResource:
    #  - 'A second CIM class definition' caused by modules (e.g. PowerShellGet)
    #    existing in both RequiredModules and a system module path.
    #  - Empty-path errors caused by trailing separators in PSModulePath.
    # Use try/catch for terminating RemoteExceptions and 2>$null for Write-Error output.
    try
    {
        $dscResources = Get-DscResource -Module $moduleUnderTest.Name -ErrorAction SilentlyContinue 2>$null
    }
    catch
    {
        # Non-critical – resource discovery issues surface during compilation below.
    }
    $here = $PSScriptRoot

    # SqlPermissions are in conflict with the Scom* resources
    $skippedDscResources = 'PowerShellRepositories', 'RemoteDesktopCollections', 'RemoteDesktopDeployment'

    Import-Module -Name datum

    $datum = New-DatumStructure -DefinitionFile $here\Assets\Datum.yml
    $allNodes = Get-Content -Path $here\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

    Write-Host 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
    try
    {
        Initialize-DscResourceMetaInfo -ModulePath $RequiredModulesDirectory -ErrorAction SilentlyContinue 2>$null
    }
    catch
    {
        Write-Warning "Initialize-DscResourceMetaInfo failed: $_"
    }
    Write-Host 'Done'

    $global:configurationData = @{
        AllNodes = [array]$allNodes
        Datum    = $Datum
    }

    # Build test cases from DSC resource folders so that resources which fail to
    # load via Get-DscResource still get a test case and the compilation step
    # (running in Windows PowerShell 5.1) reports the actual error.
    $dscResourceFolders = Get-ChildItem -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*" -Directory

    [hashtable[]]$testCases = @()
    foreach ($folder in $dscResourceFolders)
    {
        $testCases += @{
            DscResourceName = $folder.BaseName
            Skip            = ($folder.BaseName -in $skippedDscResources)
        }
    }

    $compositeResources = Get-DscResource -Module $moduleUnderTest.Name
    $finalTestCases = @()
    $finalTestCases += @{
        AllCompositeResources            = $compositeResources.Name
        FilteredCompositeResources       = $compositeResources | Where-Object Name -NotIn $skippedDscResources
        AllCompositeResourceFolders      = Get-ChildItem -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*"
        FilteredCompositeResourceFolders = Get-ChildItem -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*" | Where-Object BaseName -NotIn $skippedDscResources
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

        # Detect if running on PowerShell 7+ where DSC Configuration keyword
        # is loaded via WinPSCompatSession, causing Tuple deserialization issues.
        $script:useWinPS = $PSVersionTable.PSVersion.Major -ge 6
        if ($script:useWinPS)
        {
            $script:assetsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Assets'
            $script:modulePath = Split-Path -Path (Split-Path -Path $moduleUnderTest.ModuleBase -Parent) -Parent

            # Collect the names of all non-skipped resources and compile them
            # in a single Windows PowerShell 5.1 process.  This avoids the
            # expensive per-resource overhead of module imports and
            # Initialize-DscResourceMetaInfo.
            $skipped = @('PowerShellRepositories', 'RemoteDesktopCollections', 'RemoteDesktopDeployment')
            $resourceNames = Get-ChildItem -Path "$($moduleUnderTest.ModuleBase)\DSCResources\*" -Directory |
                Where-Object { $_.BaseName -notin $skipped } |
                ForEach-Object { $_.BaseName }
            $namesCsv = $resourceNames -join ','

            $batchScript = Join-Path -Path $PSScriptRoot -ChildPath 'CompileDscConfigurations.ps1'
            $script:resultFile = Join-Path -Path $OutputDirectory -ChildPath 'DscCompileResults.json'

            # Run the batch compilation with real-time console output.
            # We use the .NET Process API so we can redirect stdout, read it
            # line by line, and forward each line immediately to the console's
            # stderr stream via [Console]::Error.  This bypasses Pester 5's
            # PowerShell-level output capture while preserving full environment
            # inheritance (including PSModulePath).  Results are read from a
            # JSON file written by the batch script.
            $argString = @(
                '-NoProfile', '-NonInteractive',
                '-File', "`"$batchScript`"",
                '-DscResourceNames', "`"$namesCsv`"",
                '-ModuleName', $moduleUnderTest.Name,
                '-OutputPath', "`"$OutputDirectory`"",
                '-AssetsPath', "`"$($script:assetsPath)`"",
                '-RequiredModulesPath', "`"$RequiredModulesDirectory`"",
                '-ModulePath', "`"$($script:modulePath)`"",
                '-ResultPath', "`"$($script:resultFile)`""
            ) -join ' '

            $psi = [System.Diagnostics.ProcessStartInfo]::new()
            $psi.FileName               = 'powershell.exe'
            $psi.Arguments              = $argString
            $psi.UseShellExecute        = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError  = $true
            $psi.CreateNoWindow         = $true

            $proc = [System.Diagnostics.Process]::new()
            $proc.StartInfo = $psi
            $proc.Start() | Out-Null

            # Read stderr asynchronously to prevent pipe deadlocks
            $stderrTask = $proc.StandardError.ReadToEndAsync()

            # Stream stdout line by line → [Console]::Error (bypasses Pester)
            while ($null -ne ($line = $proc.StandardOutput.ReadLine()))
            {
                [Console]::Error.WriteLine($line)
                [Console]::Error.Flush()
            }

            $proc.WaitForExit()
            $script:batchExitCode = $proc.ExitCode
            $proc.Dispose()

            # Read the JSON results written by the batch script.
            if (Test-Path -Path $script:resultFile)
            {
                $script:compileResults = Get-Content -Path $script:resultFile -Raw | ConvertFrom-Json
            }
            else
            {
                $script:compileResults = @()
                Write-Warning 'Batch compilation did not produce a results file.'
            }
        }
    }

    It "'<DscResourceName>' compiles" -TestCases $testCases {

        if ($Skip)
        {
            Set-ItResult -Skipped -Because "Tests for '$DscResourceName' are skipped"
        }

        if ($script:useWinPS)
        {
            # Look up the pre-computed result from the batch compilation.
            $resourceResult = $script:compileResults | Where-Object { $_.Name -eq $DscResourceName }
            if (-not $resourceResult)
            {
                throw "No compilation result found for '$DscResourceName'. The batch compilation may have failed entirely."
            }
            if (-not $resourceResult.Success)
            {
                throw "DSC compilation failed for '$DscResourceName':`n$($resourceResult.Error)"
            }
        }
        else
        {
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

            $dscConfiguration = $dscConfiguration.Replace('#<importStatements>', "Import-DscResource -Module $($moduleUnderTest.Name) -Name $($DscResourceName)")
            Invoke-Expression -Command $dscConfiguration

            {
                & "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $OutputDirectory -ErrorAction Stop
            } | Should -Not -Throw
        }
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
