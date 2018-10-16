function Set-PSModulePath {
    param(
        [String[]]
        $ModuleToLeaveLoaded,

        [String[]]
        $PathsToSet = @()
    )

    if (Get-Module -Name PSDesiredStateConfiguration) {
        Remove-Module -Name PSDesiredStateConfiguration -Force
    }

    $env:PSModulePath = Join-Path -Path $PSHOME -ChildPath Modules
    $programFilesPath = Join-Path -Path ([System.Environment]::GetFolderPath('ProgramFiles')) -ChildPath 'WindowsPowerShell\Modules'
    $env:PSModulePath += ";$programFilesPath"

    Get-Module | Where-Object { $_.Name -notin $ModuleToLeaveLoaded } | Remove-Module -Force

    $PathsToSet.Foreach{
        if ($_ -notin ($env:PSModulePath -split ';')) {
            $env:PSModulePath = "$_;$($env:PSModulePath)"
        }
    }

    $duplicateModules = Get-Module -ListAvailable | Group-Object -Property Name, Version | Where-Object Count -gt 1
    Write-Host "Found $($duplicateModules.Count) duplicate modules"
    Write-Host 'Removing modules...'
    foreach ($duplicateModule in $duplicateModules.Group) {
        Write-Host "`t$($duplicateModule.Name)"
        foreach ($path in $PathsToSet) {

            if ($duplicateModule.Path -like "$path*") {
                $path = "$path\$($duplicateModule.Name)"
                Remove-Item -Path $path -Recurse -Force
            }
        }
    }
}