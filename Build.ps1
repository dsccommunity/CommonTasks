[cmdletBinding()]
Param (
    [Parameter(Position = 0)]
    $Tasks,

    [switch]
    $ResolveDependency,

    [switch]
    $DownloadDscResources,

    [String]
    $BuildOutput = "BuildOutput",

    [String[]]
    $GalleryRepository,

    [Uri]
    $GalleryProxy
)

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
$buildModulesPath = Join-Path -Path $BuildOutput -ChildPath Modules
$projectPath = $PSScriptRoot
$timeStamp = Get-Date -UFormat "%Y%m%d-%H%M%S"
$psVersion = $PSVersionTable.PSVersion.Major
$lines = '----------------------------------------------------------------------'

if (-not (Get-Module -Name PackageManagement)) {
    Import-Module -Name PackageManagement #import it before the PSModulePath is changed prevents PowerShell from loading it
}

if (-not (Test-Path -Path $buildModulesPath)) {
    $null = mkdir -Path $buildModulesPath -Force
}

if ($buildModulesPath -notin ($Env:PSModulePath -split ';')) {
    $env:PSModulePath = "$buildModulesPath;$Env:PSModulePath"
}

if (-not (Get-Module -Name InvokeBuild -ListAvailable) -and -not $ResolveDependency) {
    Write-Error "Requirements are missing. Please call the script again with the switch 'ResolveDependency'"
    return
}

if ($ResolveDependency) {
    . $PSScriptRoot/Build/BuildHelpers/Resolve-Dependency.ps1
    Resolve-Dependency
}

Get-ChildItem -Path "$PSScriptRoot/Build/" -Recurse -Include *.ps1 |
    ForEach-Object {
    Write-Verbose "Importing file $($_.BaseName)"
    try {
        . $_.FullName
    }
    catch { }
}

if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    if ($ResolveDependency -or $PSBoundParameters['ResolveDependency']) {
        $PSBoundParameters.Remove('ResolveDependency')
    }

    if ($Help) {
        Invoke-Build ?
    }
    else {
        Invoke-Build -Tasks $Tasks -File $MyInvocation.MyCommand.Path @PSBoundParameters
    }

    return
}

task . ClearBuildOutput,
Init,
SetPsModulePath,
CopyModule,
Test,
Deploy

task Download_All_Dependencies -if ($DownloadDscResources -or $Tasks -contains 'Download_All_Dependencies') DownloadDscResources -Before SetPsModulePath