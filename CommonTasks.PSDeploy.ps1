if (-not (Get-PackageProvider -Name PowerShellGet | Where-Object Version -ge 2.0.0.0))
{
    Import-PackageProvider PowerShellGet -MinimumVersion 2.0.0.0 -Force
}

if ($env:BHBuildSystem -ne 'Unknown' -and $env:BHBranchName -eq "master") {
    Deploy Module {
        By PSGalleryModule {
            FromSource "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
            To PSGallery
            WithOptions @{
                ApiKey = $ENV:NugetApiKey
            }
        }
    }
}
else {
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Module path is valid (Current: $(Join-Path $ENV:BHProjectPath $ENV:BHProjectName))" |
        Write-Host
}

# Publish to AppVeyor if we're in AppVeyor
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