Task IntegrationTest {
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    # Run Script Analyzer
    $start = Get-Date
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Running
    }
    $scriptAnalyerResults = Invoke-ScriptAnalyzer -Path (Join-Path -Path $env:BHProjectPath -ChildPath $ENV:BHProjectName) -Recurse -Severity Error -ErrorAction SilentlyContinue
    $end = Get-Date
    $duration = [long]($end - $start).TotalMilliSeconds
    
    if ($scriptAnalyerResults -and $ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity." -Category Error

        Update-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Failed -ErrorMessage ($scriptAnalyerResults | Out-String) -Duration $duration
    }
    elseif ($env:BHBuildSystem -eq 'AppVeyor') {
        Update-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Passed -Duration ([long]($end - $start).TotalMilliSeconds)
    }

    # Gather test results. Store them in a variable and file
    $testFileName = "IntegrationTestResults.xml"
    $testResultPath = "$(property BHBuildOutput)\Pester"
    if (-not (Test-Path -Path $testResultPath)) {
        mkdir -Path $testResultPath -ErrorAction SilentlyContinue | Out-Null
    }
    $testResults = Invoke-Pester -Path "$(property BHPSModulePath)\Tests\Integration" -PassThru -OutputFormat NUnitXml -OutputFile "$(property BHBuildOutput)\Pester\$testFileName"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$(property BHBuildOutput)\Pester\$testFileName")
    }

    assert ($testResults.FailedCount -eq 0)
    if ($testResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"      
    }
    "`n"
}