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
}