$moduleName = $env:BHProjectName

Describe 'General module control' -Tags FunctionalQuality {
    
    It 'Imports without errors' {
        { Import-Module -Name $moduleName -Force -ErrorAction Stop } | Should -Not -Throw
        Get-Module -Name $moduleName | Should -Not -BeNullOrEmpty
    }

    It 'Removes without error' {
        { Remove-Module -Name $moduleName -ErrorAction Stop} | Should -Not -Throw
        Get-Module $moduleName | Should -BeNullOrEmpty
    }
}
