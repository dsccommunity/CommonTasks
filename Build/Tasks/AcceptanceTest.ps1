Task AcceptanceTest {
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    $sourceDirectory = "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory"
    
    $testFileName = "AcceptanceTestResults.xml"
    $testResultPath = "$sourceDirectory\BuildOutput\Pester"
    if (-not (Test-Path -Path $testResultPath)) {
        mkdir -Path $testResultPath -ErrorAction SilentlyContinue | Out-Null
    }
    $testResults = Invoke-Pester -Path "$sourceDirectory\Tests\Acceptance" -PassThru -OutputFormat NUnitXml -OutputFile "$sourceDirectory\Pester\$testFileName"

    assert ($testResults.FailedCount -eq 0)
    if ($testResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"      
    }
    "`n"
}