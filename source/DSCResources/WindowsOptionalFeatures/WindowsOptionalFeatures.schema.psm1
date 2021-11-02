configuration WindowsOptionalFeatures {
    param (
        [Parameter(Mandatory)]
        [string[]]$Name,

        [Boolean]
        $RemoveFilesOnDisable = $false,

        [Boolean]
        $NoWindowsUpdateCheck = $false
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    foreach ($n in $Name)
    {
        $ensure = 'Enable'

        if ($n[0] -in '-', '+')
        {
            if ($n[0] -eq '-')
            {
                $ensure = 'Disable'
            }
            $n = $n.Substring(1)
        }

        $params = @{
            Name                 = $n
            Ensure               = $ensure
            RemoveFilesOnDisable = $RemoveFilesOnDisable
            NoWindowsUpdateCheck = $NoWindowsUpdateCheck
        }

        (Get-DscSplattedResource -ResourceName WindowsOptionalFeature -ExecutionName $params.Name -Properties $params -NoInvoke).Invoke($params)
    }
}
