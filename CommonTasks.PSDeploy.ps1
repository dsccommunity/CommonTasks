if ($env:BHBuildSystem -eq 'AppVeyor' -and $env:BHBranchName -eq "master") {
    Deploy Module {
        By PSGalleryModule {
            FromSource "$($env:BHBuildOutput)\Modules\$($env:BHProjectName)"
            To PSGallery
            WithOptions @{
                ApiKey = $env:NugetApiKey
                Force = $true
            }
        }
    }
}
elseif ($env:BUILD_REPOSITORY_PROVIDER -eq 'TfsGit' -and $env:BUILD_SOURCEBRANCHNAME -eq "master") {
    Deploy Module {
        By PSGalleryModule {
            FromSource "$($env:AGENT_RELEASEDIRECTORY)\$($env:BUILD_DEFINITIONNAME)\SourcesDirectory\BuildOutput\Modules\$($env:BUILD_REPOSITORY_NAME)"
            To PowerShell
            WithOptions @{
                ApiKey = 'install@contoso.com:Somepass1'
                Force = $true
            }
        }
    }
}
else {
    $modulePath = if ($env:BHProjectPath -and $env:BHProjectName) {
        $(Join-Path -Path $env:BHProjectPath -ChildPath $env:BHProjectName)
    }
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Module path is valid (Current: )" |
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