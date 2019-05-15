Configuration WindowsFeatures {
    Param(
        [Parameter(Mandatory)]
        [string[]]$Name
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.6.0.0

    $ensure = 'Present'
    foreach ($n in $Name) {

        if ($n[0] -in '-', '+') {
            if ($n[0] -eq '-') {
                $ensure = 'Absent'
            }
            else {
                $ensure = 'Present'
            }
            $n = $n.Substring(1)
        }

        $params = @{
            Name                 = $n
            Ensure               = $ensure
            IncludeAllSubFeature = $true
        }

        (Get-DscSplattedResource -ResourceName xWindowsFeature -ExecutionName $params.Name -Properties $params -NoInvoke).Invoke($params)
    }
}