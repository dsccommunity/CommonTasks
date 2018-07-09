task SetPsModulePath {
    if (-not ([System.IO.Path]::IsPathRooted($BuildOutput)))
    {        
        $BuildOutput = Join-Path -Path $ProjectPath -ChildPath $BuildOutput        
    }
    
    $configurationPath = Join-Path -Path $ProjectPath -ChildPath $ConfigurationsFolder
    $resourcePath = Join-Path -Path $ProjectPath -ChildPath $ResourcesFolder
    $buildModulesPath = Join-Path -Path $BuildOutput -ChildPath Modules
    
    $moduleToLeaveLoaded = 'InvokeBuild', 'PSReadline', 'PackageManagement', 'ISESteroids'
    Set-PSModulePath -ModuleToLeaveLoaded $moduleToLeaveLoaded -PathsToSet $buildModulesPath, $env:BHBuildOutput
}