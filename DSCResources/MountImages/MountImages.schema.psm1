configuration MountImages
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable[]]
        $Images
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName StorageDsc

    foreach ($img in $Images)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $img = @{}+$img

        $imgName = $img.ImagePath -replace ':|\s', ''
        $executionName = "MountImage_$imgName"

        if (-not $img.ContainsKey('Ensure'))
        {
            $img.Ensure = 'Present'
        }

        if (-not $img.ContainsKey('Access'))
        {
            $img.Access = 'ReadOnly'
        }

        (Get-DscSplattedResource -ResourceName MountImage -ExecutionName $executionName -Properties $img -NoInvoke).Invoke($img)

        if( ($img.Ensure -eq 'Present') -and ($img.ContainsKey('DriveLetter')) )
        {
            # wait for volume: 30s
            WaitForVolume "WaitForDrive_$($img.DriveLetter)"
            {
                DriveLetter      = $img.DriveLetter
                RetryIntervalSec = 5
                RetryCount       = 6
                DependsOn        = "[MountImage]$executionName"
            }    
        }
    }
}
