#take the first trusted gallery to test against, otherwise the PSGallery. This is sufficient for this demo
$repository = Get-PSRepository | Where-Object InstallationPolicy -eq Trusted -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $repository)
{
    $repository = Get-PSRepository -Name PSGallery
}
$repositoryName = $repository.Name
$moduleName = 'CommonTasks'

Describe "Module '$moduleName' can be uninstalled" -Tags 'FunctionalQuality' {
    It 'Offers as least one DSC Resource' {
        { if (Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue) {
            Uninstall-Module -Name $moduleName -ErrorAction stop
        } } | Should Not Throw
    }
}