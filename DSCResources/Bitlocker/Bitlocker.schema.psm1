configuration Bitlocker
{
    param
    (
        [Parameter()]
        [Hashtable]
        $Tpm,

        [Parameter()]
        [Hashtable[]]
        $Disks,

        [Parameter()]
        [Hashtable[]]
        $AutoDisks
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xBitlocker

    # First install the required Bitlocker features
    WindowsFeature BitlockerFeature
    {
        Name                 = 'Bitlocker'
        Ensure               = 'Present'
        IncludeAllSubFeature = $true
    }

    WindowsFeature BitlockerToolsFeature
    {
        Name                 = 'RSAT-Feature-Tools-Bitlocker'
        Ensure               = 'Present'
        IncludeAllSubFeature = $true
    }
    
    $nextDepends = @( '[WindowsFeature]BitlockerFeature', '[WindowsFeature]BitlockerToolsFeature' )

    if( $null -ne $Tpm )
    {
        $Tpm.Identity = 'bitlocker_Tpm'
        $Tpm.DependsOn = $nextDepends

        (Get-DscSplattedResource -ResourceName xBLTpm -ExecutionName $Tpm.Identity -Properties $Tpm -NoInvoke).Invoke($Tpm)

        $nextDepends = "[xBLTpm]$($Tpm.Identity)"
    }

    [boolean]$sysDrivePresent = $false

    if( $null -ne $Disks )
    {
        foreach ($disk in $Disks) 
        {
            $disk.DependsOn = $nextDepends

            $executionName = "bitlocker_$($disk.MountPoint -replace '[().:\s]', '')"
            (Get-DscSplattedResource -ResourceName xBLBitlocker -ExecutionName $executionName -Properties $disk -NoInvoke).Invoke($disk)

            # first drive in list is the system drive
            if( $sysDrivePresent -eq $false )
            {
                $sysDrivePresent = $true
                $nextDepends = "[xBLBitlocker]$executionName"
            }
        }
    }

    if( $null -ne $AutoDisks )
    {
        # system drive encryption is required
        if( $sysDrivePresent -eq $false )
        {
            throw "ERROR: Before using 'Bitlocker - AutoDisks' the system drive encryption must be specified in the 'Bitlocker - Disks' section."
        }

        foreach ($autoDisk in $AutoDisks) 
        {
            $autoDisk.DependsOn = $nextDepends

            $executionName = "bitlocker_$($autoDisk.DriveType)"
            (Get-DscSplattedResource -ResourceName xBLAutoBitlocker -ExecutionName $executionName -Properties $autoDisk -NoInvoke).Invoke($autoDisk)
        }
    }
}
