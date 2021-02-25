Describe 'Final tests' -Tags FunctionalQuality {

    It 'Every composite resource has compiled' {

        $compositeResouces = Get-DscResource -Module CommonTasks
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        $mofFiles = Get-ChildItem -Path $env:BHBuildOutput -Filter *.mof
        Write-Host "Number of compiled MOF files: $($mofFiles.Count)"

        $compositeResouces.Count | Should -Be $mofFiles.Count
    }

    It 'Composite resource folder count matches composite resource count' {

        $compositeResouces = Get-DscResource -Module CommonTasks
        $compositeResouceFolders = dir -Path "$env:BHBuildOutput\Modules\$env:BHProjectName\DscResources"
        Write-Host "Number of composite resource folders: $($compositeResouceFolders.Count)"
        Write-Host "Number of composite resources: $($compositeResouces.Count)"
        Write-Host (Compare-Object -ReferenceObject $compositeResouceFolders.Name -DifferenceObject $compositeResouces.Name | Out-String) -ForegroundColor Yellow
        
        $compositeResouces.Count | Should -Be $compositeResouceFolders.Count
    }
}
