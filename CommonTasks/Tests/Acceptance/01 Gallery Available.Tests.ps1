$moduleName = 'CommonTasks'
$repositoryName = 'PowerShell'
Describe "$moduleName is available on the gallery" -Tags 'FunctionalQuality' {
    It 'Can be found' {
        Find-Module -Name $moduleName -Repository $repositoryName | Should Not BeNullOrEmpty
    }

    It 'Can be installed' {
        { Install-Module -Name $moduleName -Repository $repositoryName } | Should Not Throw
    }

    It 'Offers as least one DSC Resource' {
        Get-DscResource -Module $moduleName | Should Not BeNullOrEmpty
    }

    AfterAll {
        if (Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue) {
            Uninstall-Module -Name $moduleName
        }
    }

}

