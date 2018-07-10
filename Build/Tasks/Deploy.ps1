Task Deploy {
    Write-Host "Starting deployment with files inside $ProjectRoot"

    $Params = @{
        Path    = $ProjectRoot
        Force   = $true
        Recurse = $false
        Verbose = $true
    }
    Invoke-PSDeploy @Params
}