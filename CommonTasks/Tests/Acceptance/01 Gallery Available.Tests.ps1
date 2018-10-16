#take the first trusted gallery to test against, otherwise the PSGallery. This is sufficient for this demo
$repository = Get-PSRepository | Where-Object InstallationPolicy -eq Trusted -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $repository)
{
    $repository = Get-PSRepository -Name PSGallery
}
$repositoryName = $repository.Name
$moduleName = 'CommonTasks'

Describe "Module '$moduleName' is available on the repository '$repositoryName'" -Tags 'FunctionalQuality' {
    It 'Can be found' {
        Find-Module -Name $moduleName -Repository $repositoryName | Should Not BeNullOrEmpty
    }

    It "Module '$moduleName' can be installed" {
        { Install-Module -Name $moduleName -Repository $repositoryName -Scope CurrentUser } | Should Not Throw
    }
}