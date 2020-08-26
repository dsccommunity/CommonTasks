Describe 'Final tests' -Tags FunctionalQuality {

    It 'Every composite resource has compiled' {

        $compositeResouces = Get-DscResource -Module CommonTasks
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        $mofFiles = Get-ChildItem -Path $env:BHBuildOutput -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"

        $compositeResouces.Count | Should -Be $mofFiles.Count
    }
}
