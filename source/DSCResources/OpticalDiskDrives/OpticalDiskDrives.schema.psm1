configuration OpticalDiskDrives
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Drives
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName StorageDsc

    foreach ($drive in $Drives)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $drive = @{} + $drive

        if (-not $drive.ContainsKey('Ensure'))
        {
            $drive.Ensure = 'Present'
        }

        if ($drive.Ensure -eq 'Absent' -and -not $drive.ContainsKey('DriveLetter'))
        {
            $drive.DriveLetter = 'Z'  # unused but required
        }

        (Get-DscSplattedResource -ResourceName OpticalDiskDriveLetter -ExecutionName "optDiskDrive$($drive.DiskId)" -Properties $drive -NoInvoke).Invoke($drive)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
