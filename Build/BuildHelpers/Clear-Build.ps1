param (
    [System.IO.DirectoryInfo]
    $ProjectPath = (property ProjectPath $BuildRoot),

    [string]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [string]
    $LineSeparation = (property LineSeparation ('-' * 78)) 
)

task ClearBuildOutput {
    # Synopsis: Clears the BuildOutput folder from its artefacts, but leaves the modules subfolder and its content. 

    if (-not [System.IO.Path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }
    if (Test-Path -Path $BuildOutput) {
        "Removing $BuildOutput\*"
        Get-ChildItem -Path $BuildOutput -Exclude Modules, README.md | Remove-Item -Force -Recurse -ErrorAction Stop
    }
}

task ClearModules {
    # Synopsis: Clears the content of the BuildOutput folder INCLUDING the modules folder
    if (![System.IO.Path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }
    "Removing $BuildOutput\*"
    Get-ChildItem -Path $BuildOutput | Remove-Item -Force -Recurse -ErrorAction Stop
}