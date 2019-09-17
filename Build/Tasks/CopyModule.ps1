task CopyModule {

    # Bump the module version
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $env:APPVEYOR_BUILD_VERSION
    }
    elseif ($env:BHBuildSystem -in 'VSTS', 'Azure Pipelines') {
        $currentVersion = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion
        
        $newVersion = $currentVersion.Split('.')
        $newVersion[-1] = $env:BHBuildNumber
        $newVersion = $newVersion -join '.'

        Write-Host "Current version is '$currentVersion', new version will be '$newVersion'" -ForegroundColor Green

        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $newVersion
    }

    Write-Host "Copy folder '$($projectPath.FullName)\$($env:BHProjectName)' to '$buildOutput\Modules'"-ForegroundColor Green
    Copy-Item -Path "$($projectPath.FullName)\$($env:BHProjectName)" -Destination "$buildOutput\Modules" -Recurse -Force

}
