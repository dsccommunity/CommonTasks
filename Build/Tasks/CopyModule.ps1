task CopyModule {

    # Bump the module version
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $env:APPVEYOR_BUILD_VERSION
    }
    elseif ($env:BHBuildSystem -eq 'VSTS') {
        $currentVersion = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion

        $currentVersion = $currentVersion.Split('.')
        $currentVersion[-1] = $env:BHBuildNumber
        $currentVersion = $currentVersion -join '.'

        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $currentVersion
    }

    Write-Build Green "Copy folder '$projectPath\CommonTasks' to '$buildOutput'" Green
    Copy-Item -Path $projectPath\CommonTasks -Destination $buildOutput\Modules -Recurse -Force

}