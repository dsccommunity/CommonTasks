# Custom Build Tasks

This folder is where you can Add custom Build task and they will be imported by the `.build.ps1` file via this scriptblock:
```PowerShell
 Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
        Foreach-Object {
            "Importing file $($_.BaseName)" | Write-Verbose
            . $_.FullName 
        }
```