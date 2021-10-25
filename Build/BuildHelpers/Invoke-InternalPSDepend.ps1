function Invoke-PSDependInternal {
    param([Parameter(Mandatory)]
        [hashtable]$PSDependParameters,

        [Parameter(Mandatory)]
        [string]$Reporitory
    )

    if (-not $PSDependParameters.ContainsKey('Path')) {
        Write-Error 'Path is missing in PSDependParameters'
        return
    }

    $psDependFilePath = $PSDependParameters.Path
    if (-not (Test-Path -Path $psDependFilePath)) {
        Write-Error "The path '$psDependFilePath' does not exist"
        return
    }

    $content = Get-Content -Path $psDependFilePath -Raw
    $newString = "Repository = '$Reporitory'"
    $content = $content -replace "Repository\s+=\s+'PSGallery'", $newString

    $path = "$projectPath\PSDependTemp.psd1"
    $content | Out-File $path -Force
    $PSDependParameters.Path = $path

    try {
        Invoke-PSDepend @PSDependParameters -ErrorAction Stop
    }
    catch {
        Write-Error -ErrorRecord $_
    }
    finally {
        Remove-Item -Path $path -Force
    }

}
