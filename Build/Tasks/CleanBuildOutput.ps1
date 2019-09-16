param (
    [System.IO.DirectoryInfo]
    $ProjectPath = (property ProjectPath $BuildRoot),

    [String]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [String]
    $LineSeparation = (property LineSeparation ('-' * 78)) 
)

task CleanBuildOutput {
    # Synopsis: Clears the BuildOutput folder from its artefacts, but leaves the modules subfolder and its content. 

    if (-not [System.IO.Path]::IsPathRooted($BuildOutput)) 
    {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }
    if (Test-Path $BuildOutput) 
    {
        Write-Host "Removing '$BuildOutput\*' except of the 'Modules' folder"
        Get-ChildItem -Path $BuildOutput -Exclude Modules | Remove-Item -Force -Recurse

        Write-Host "Removing '$BuildOutput\Modules\$($env:BHProjectName)'"
        Get-ChildItem -Path $BuildOutput\Modules -Filter $env:BHProjectName | Remove-Item -Force -Recurse -ErrorAction Stop
    }
}