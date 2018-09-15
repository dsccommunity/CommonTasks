Task Test {
    "`n`tSTATUS: Testing with PowerShell $PSVersion"
    # Run Script Analyzer
    $start = Get-Date
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Running
    }
    $scriptAnalyerResults = Invoke-ScriptAnalyzer -Path (Join-Path -Path $env:BHProjectPath -ChildPath $ENV:BHProjectName) -Recurse -Severity Error -ErrorAction SilentlyContinue
    $end = Get-Date
    $duration = [long]($end - $start).TotalMilliSeconds
    
    if ($scriptAnalyerResults -and $ENV:BHBuildSystem -eq 'AppVeyor')
    {
        Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity." -Category Error

        Update-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Failed -ErrorMessage ($scriptAnalyerResults | Out-String) -Duration $duration
    }
    elseif ($env:BHBuildSystem -eq 'AppVeyor')
    {
        Update-AppveyorTest -Name "PSScriptAnalyzer" -Outcome Passed -Duration ([long]($end - $start).TotalMilliSeconds)
    }

    # Gather test results. Store them in a variable and file
    $testFileName = "TestResults_Integration_PS$($PSVersion)_$($timeStamp).xml"
    $testResultPath = "$(property BHBuildOutput)\Pester"
    if (-not (Test-Path -Path $testResultPath))
    {
        mkdir -Path $testResultPath -ErrorAction SilentlyContinue | Out-Null
    }
    $testResults = Invoke-Pester -Path "$(property BHPSModulePath)\Tests" -PassThru -OutputFormat NUnitXml -OutputFile "$(property BHBuildOutput)\Pester\$testFileName"

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    if ($env:BHBuildSystem -eq 'AppVeyor')
    {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$(property BHBuildOutput)\Pester\$testFileName")
    }

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}