task DownloadDscResources {
    $psDependResourceDefinition = "$ProjectPath\PSDepend.DscResources.psd1"
    if (Test-Path -Path $PSDependResourceDefinition) {

        $psDependParams = @{
            Path    = $PSDependResourceDefinition
            Confirm = $false
            Target  = $buildModulesPath
        }
        Invoke-PSDependInternal -PSDependParameters $psDependParams -Reporitory $Repository
    }
}