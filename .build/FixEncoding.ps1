<#
    .SYNOPSIS
        Sets the encoding of all *.psd1 files to UTF8.

    .DESCRIPTION
        Sets the encoding of all *.psd1 files to UTF8. This is a build task that is

        This task is only needed when the build runs on Windows PowerShell 5.1.

    .NOTES
        This is a build task that is primarily meant to be run by Invoke-Build but
        wrapped by the Sampler project's build.ps1 (https://github.com/gaelcolas/Sampler).
#>

param ()

task FixEncoding {

    Write-Build Yellow "Setting encoding to UTF8 for *.PSD1 files in path '$BuildModuleOutput'."
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)

    Get-ChildItem -Path $BuildModuleOutput -Filter *.psd1 -Recurse -File | ForEach-Object {

        Write-Build DarkGray "`t'$($_.FullName)'."
        $c = [System.IO.File]::ReadAllLines($_.FullName)
        [System.IO.File]::WriteAllLines($_.FullName, $c, $utf8NoBomEncoding)
    }
}
