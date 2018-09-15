task CopyModule {

    # Bump the module version
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $env:APPVEYOR_BUILD_VERSION
    }

    Write-Build Green "Copy folder '$projectPath\CommonTasks' to '$buildOutput'" Green
    Copy-Item -Path $projectPath\CommonTasks -Destination $buildOutput\Modules -Recurse -Force

}