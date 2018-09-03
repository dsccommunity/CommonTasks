Configuration SoftwarePackage {
    Param(
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

        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        $executionName = $p.Name -replace '\(|\)|\.| ', ''
        (Get-DscSplattedResource -ResourceName xPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)
    }
}