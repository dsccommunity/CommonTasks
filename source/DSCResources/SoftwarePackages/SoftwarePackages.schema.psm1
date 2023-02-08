configuration SoftwarePackages {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Packages
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($p in $Packages)
    {
        $p.Ensure = 'Present'
        if (-not $p.ProductId)
        {
            $p.ProductId = ''
        }

        $executionName = $p.Name -replace '\(|\)|\.| ', ''
        (Get-DscSplattedResource -ResourceName xPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
