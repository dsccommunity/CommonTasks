Task TestReleaseAcceptance {

    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    if ($env:BHBranchName -eq 'master') {
        Write-Host "Source branch is 'master', waiting 30 seconds for the module to appear in the gallery"
        Start-Sleep -Seconds 30

        Write-Host "Build system is '$($env:BHBuildSystem)'"
        if ($env:BHBuildSystem -eq 'AppVeyor') {
            $sourcePath = "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
            $testResultsPath = "$($env:BHBuildOutput)\Pester"
        }
        elseif ($env:BUILD_REPOSITORY_PROVIDER -eq 'TfsGit') {
            
            $sourcePath = "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory\BuildOutput\Modules\$($env:BUILD_REPOSITORY_NAME)"
            $testResultsPath = "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory\BuildOutput\Pester"
        }

        Write-Host "SourcePath is '$sourcePath', TestResultPath is '$testResultsPath'"

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
    else {
        Write-Host "In branch '$($env:BHBranchName)', release tests will not be invoked."
    }    
}
