if ($env:BHBranchName -eq "master" -and $env:NugetApiKey) {
    
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
