task CopyModule {

    Copy-Item -Path $projectPath\CommonTasks -Destination $buildOutput -Recurse -Force

}