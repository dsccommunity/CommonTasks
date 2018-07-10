param (
    #[string]
    #$TestFile, #= (property TestFile '')

    #[string]
    #$x
)

Task Init {
    if (-not $env:BHProjectName) {
        Set-BuildEnvironment
    }

    $lines
    Set-Location -Path $ProjectPath
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}