param (
    #[string]
    #$TestFile, #= (property TestFile '')

    #[string]
    #$x
)

Task Init {
    Write-Host '-------------------------------------------------------------------------'
    dir env:
    Write-Host '-------------------------------------------------------------------------'
    if (-not $env:BHProjectName) {
        Set-BuildEnvironment
    }

    $lines
    Set-Location -Path $ProjectPath
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"

    Write-Host '-------------------------------------------------------------------------'
    dir env:
    Write-Host '-------------------------------------------------------------------------'
}