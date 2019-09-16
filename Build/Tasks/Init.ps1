Task Init {

    Set-Location -Path $ProjectPath
    if (-not $env:BHProjectName) {
        try {
            Write-Host "Calling 'Set-BuildEnvironment' with path '$ProjectPath'"
            Set-BuildEnvironment -Path $ProjectPath
        }
        catch {
            Write-Host "Error calling 'Set-BuildEnvironment'. The task will probably fail if in build."
            Write-Host "The error was: $($_.Exception.Message)"
        }
    }

    $lines
    "Build System Details:"
    Get-Item -Path env:BH*
    "`n"
}
