function Resolve-Dependency {
    [CmdletBinding()]
    param()

    Write-Host "Downloading dependencies, this may take a while" -ForegroundColor Green
    if (-not (Get-PackageProvider -Name NuGet -ForceBootstrap)) {
        $providerBootstrapParams = @{
            Name           = 'nuget'
            Force          = $true
            ForceBootstrap = $true
        }
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            $providerBootstrapParams.Add('Verbose', $Verbose)
        }
        if ($RepositoryProxy) {
            $providerBootstrapParams.Add('Proxy', $RepositoryProxy)
        }
        $null = Install-PackageProvider @providerBootstrapParams
    }

    if (-not (Get-Module -Name "$buildModulesPath\PSDepend" -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Verbose -Message 'BootStrapping PSDepend'    
        Write-Verbose -Message "Parameter $buildOutput"
        $installPSDependParams = @{
            Name    = 'PSDepend'
            Path    = $buildModulesPath
            Confirm = $false
        }
        if ($PSBoundParameters.ContainsKey('verbose')) {
            $installPSDependParams.Add('Verbose', $Verbose)
        }
        if ($Repository) {
            $installPSDependParams.Add('Repository', $Repository)
        }
        if ($RepositoryProxy) {
            $installPSDependParams.Add('Proxy', $RepositoryProxy)
        }
        if ($RepositoryCredential) {
            $installPSDependParams.Add('ProxyCredential', $RepositoryCredential)
        }
        Save-Module @installPSDependParams
    }

    $psDependParams = @{
        Force = $true
        Path  = "$ProjectPath\PSDepend.Build.psd1"
    }
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $psDependParams.Add('Verbose', $Verbose)
    }
    Import-Module -Name PSDepend
    Invoke-PSDependInternal -PSDependParameters $psDependParams -Reporitory $Repository
    Write-Verbose 'Project Bootstrapped, returning to Invoke-Build'
}