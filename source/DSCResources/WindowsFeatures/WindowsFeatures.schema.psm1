configuration WindowsFeatures {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]
        $Names
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($n in $Names)
    {
        $ensure = 'Present'
        $includeAllSubFeature = $false

        if ($n[0] -in '-', '+', '*')
        {
            if ($n[0] -eq '-')
            {
                $ensure = 'Absent'
            }
            elseif ($n[0] -eq '*')
            {
                $includeAllSubFeature = $true
            }
            $n = $n.Substring(1)
        }

        $params = @{
            Name                 = $n
            Ensure               = $ensure
            IncludeAllSubFeature = $includeAllSubFeature
        }

        (Get-DscSplattedResource -ResourceName WindowsFeature -ExecutionName $params.Name -Properties $params -NoInvoke).Invoke($params)
    }
}
