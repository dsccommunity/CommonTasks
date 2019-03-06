Configuration SoftwarePackage {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Package
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.5.0.0

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