configuration ChocolateyPackages {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Package
    )
    
    Import-DscResource -ModuleName Chocolatey

    foreach ($p in $Package) {        
        $executionName = $p.Name -replace '\(|\)|\.| ', ''
        $executionName = "Chocolatey_$executionName"
        $p.ChocolateyOptions = [hashtable]$p.ChocolateyOptions
        (Get-DscSplattedResource -ResourceName ChocolateyPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)
    }
}
