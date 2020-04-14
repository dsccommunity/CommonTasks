$configData = Import-LocalizedData -BaseDirectory $PSScriptRoot\Assets -FileName Config1.psd1 -SupportedCommand New-Object, ConvertTo-SecureString -ErrorAction Stop
$moduleName = $env:BHProjectName

Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
Import-Module -Name $env:BHProjectName -ErrorAction Stop

Import-Module -Name DscBuildHelpers

Describe 'Final tests' -Tags 'FunctionalQuality' {
    It 'Every composite resource has compiled' {
        $compositeResouces = Get-DscResource -Module CommonTasks
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        $mofFiles = Get-ChildItem -Path $env:BHBuildOutput -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"

        $compositeResouces.Count | Should -Be $mofFiles.Count
    }
}
