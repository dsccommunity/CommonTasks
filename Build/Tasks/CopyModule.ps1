task CopyModule {

    # Bump the module version
    if ($env:BHBuildSystem -eq 'AppVeyor') {
        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $env:APPVEYOR_BUILD_VERSION
    }
    elseif ($env:BHBuildSystem -eq 'VSTS') {
        $currentVersion = Get-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion
        
        $newVersion = $currentVersion.Split('.')
        $newVersion[-1] = $env:BHBuildNumber
        $newVersion = $newVersion -join '.'

        Write-Build Green "Current version is '$currentVersion', new version will be '$newVersion'"

        Update-Metadata -Path $env:BHPSModuleManifest -Verbose -Value $newVersion
    }

    Write-Build Green "Copy folder '$projectPath\CommonTasks' to '$buildOutput'" Green
    Copy-Item -Path $projectPath\CommonTasks -Destination $buildOutput\Modules -Recurse -Force

}