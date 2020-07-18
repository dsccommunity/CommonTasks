configuration SoftwarePackages {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Package
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($p in $Package) {
        $p.Ensure = 'Present'
        if (-not $p.ProductId)
        {
            $p.ProductId = ''
        }
        
        $executionName = $p.Name -replace '\(|\)|\.| ', ''
        (Get-DscSplattedResource -ResourceName xPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)
    }
}
