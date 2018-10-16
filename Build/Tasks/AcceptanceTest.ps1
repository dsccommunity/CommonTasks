Task AcceptanceTest {

    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    Start-Sleep -Seconds 30 #to wait until the module is available in the gallery

    if ($env:BHBuildSystem -eq 'AppVeyor' -and $env:BHBranchName -eq "master") {
        $sourcePath = "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
        $testResultsPath = "$($env:BHBuildOutput)\Pester"
    }
    elseif ($env:BUILD_REPOSITORY_PROVIDER -eq 'TfsGit' -and $env:BUILD_SOURCEBRANCHNAME -eq "master") {
        
        $sourcePath = "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory\BuildOutput\Modules\$($env:BUILD_REPOSITORY_NAME)"
        $testResultsPath = "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory\BuildOutput\Pester"
    }

    if ($sourcePath) {
        $testFileName = "AcceptanceTestResults.xml"
        if (-not (Test-Path -Path $testResultsPath)) {
            mkdir -Path $testResultsPath -ErrorAction SilentlyContinue | Out-Null
        }
        $testResults = Invoke-Pester -Path "$sourcePath\Tests\Acceptance" -PassThru -OutputFormat NUnitXml -OutputFile "$testResultsPath\$testFileName"

        assert ($testResults.FailedCount -eq 0)
        if ($testResults.FailedCount -gt 0) {
            Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"      
        }
        "`n"
    }
}