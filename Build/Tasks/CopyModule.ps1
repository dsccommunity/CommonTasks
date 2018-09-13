task CopyModule {

    Write-Build Green "Copy folder '$projectPath\CommonTasks' to '$buildOutput'" Green
    Copy-Item -Path $projectPath\CommonTasks -Destination $buildOutput\Modules -Recurse -Force

}