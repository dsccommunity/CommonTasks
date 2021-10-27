$nugetPathAllUsers = "$([System.Environment]::GetFolderPath('CommonApplicationData'))\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"
$nugetPathCurrentUser = "$([System.Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"

$hasNuget = if (Test-Path -Path $nugetPathAllUsers) {

    $nugetExe = Get-Item -Path $nugetPathAllUsers
    Write-Host "'nuget.exe' exist in '$nugetPathAllUsers' with version '$($nugetExe.VersionInfo.FileVersionRaw)'"
    
    if ($nugetExe.VersionInfo.FileVersionRaw -gt '5.11') {
        $true
    }
}

if (-not $hasNuget) {
    if (Test-Path -Path $nugetPathCurrentUser) {

        $nugetExe = Get-Item -Path $nugetPathCurrentUser
        Write-Host "'nuget.exe' exist in '$nugetPathCurrentUser' with version '$($nugetExe.VersionInfo.FileVersionRaw)'"
    
        if ($nugetExe.VersionInfo.FileVersionRaw -gt '5.11') {
            $hasNuget = $true
        }
    }
}

if (-not $hasNuget)
{
    Write-Host "'Nuget.exe' does not exist in ProgramData nor the local users profile, downloading into the users profile..."

    Invoke-WebRequest -Uri 'https://aka.ms/psget-nugetexe' -OutFile $nugetPathCurrentUser -ErrorAction Stop
    

    if (Test-Path -Path $nugetPathCurrentUser) {
        $nugetExe = Get-Item -Path $nugetPathCurrentUser -ErrorAction SilentlyContinue
        Write-Host "'nuget.exe' exist in '$nugetPathCurrentUser' with version '$($nugetExe.VersionInfo.FileVersionRaw)'"

        if ($nugetExe.VersionInfo.FileVersionRaw -lt '5.11') {
            Write-Host "'nuget.exe' has the version '$($nugetExe.VersionInfo.FileVersionRaw)' and needs to be updated."
            Invoke-WebRequest -Uri 'https://aka.ms/psget-nugetexe' -OutFile $nugetPathCurrentUser -ErrorAction Stop
        }
    }
    else
    {
        Write-Host "'nuget.exe' does not exist in the local profile and will be downloaded."
        Invoke-WebRequest -Uri 'https://aka.ms/psget-nugetexe' -OutFile $nugetPathCurrentUser -ErrorAction Stop
    }
}
else
{
    Write-Host "OK: NuGet version $($nugetExe.VersionInfo.FileVersionRaw) in directory '$($nugetExe.Directory)' works"
}

if ($env:BHBranchName -eq 'master' -and $env:NugetApiKey) {
    
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Deploy Module {
            By PSGalleryModule {
                FromSource "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
                To PSGallery
                WithOptions @{
                    ApiKey = $env:NugetApiKey
                    Force  = $true
                }
            }
        }
    }
    elseif ($env:BHBuildSystem -eq 'Azure Pipelines') {
        Deploy Module {
            By PSGalleryModule {
                FromSource "$($env:AGENT_RELEASEDIRECTORY)\$($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS)\SourcesDirectory\BuildOutput\Modules\$($env:BUILD_REPOSITORY_NAME)"
                To PowerShell
                WithOptions @{
                    ApiKey = $env:NuGetApiKey
                    Force  = $true
                }
            }
        }
    }

}
else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $env:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $env:BHBranchName) `n" +
    "`t* The NugetApiKey is known (value as bool is '$([bool]$env:NugetApiKey)') `n" +
    "`t* Module path is valid (Current: )" |
        Write-Host
}

# Publish to AppVeyor if we're in AppVeyor also for dev branch
if ($env:BHBuildSystem -eq 'AppVeyor') {
    Write-Host "Creating build with version '$($env:APPVEYOR_BUILD_VERSION)'"
    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
            To AppVeyor
            WithOptions @{
                Version = $env:APPVEYOR_BUILD_VERSION
            }
        }
    }
}
