task DownloadDscResources {
    $psDependResourceDefinition = "$ProjectPath\PSDepend.DscResources.psd1"
    if (Test-Path -Path $PSDependResourceDefinition) {
        Invoke-PSDepend -Path $psDependResourceDefinition -Confirm:$false -Target $buildModulesPath
    }
}