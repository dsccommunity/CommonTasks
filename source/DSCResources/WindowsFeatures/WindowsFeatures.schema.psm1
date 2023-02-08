configuration WindowsFeatures {
    param (
        [Parameter()]
        [string[]]
        $Names,

        [Parameter()]
        [hashtable[]]
        $Features
    )

    $curPSModulePath = $env:PSModulePath

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

    <#
    @{
    Name = [string]
    [Credential = [PSCredential]]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [IncludeAllSubFeature = [bool]]
    [LogPath = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [Source = [string]]
}
    #>
    foreach ($feature in $Features)
    {
        (Get-DscSplattedResource -ResourceName WindowsFeature -ExecutionName $feature.Name -Properties $feature -NoInvoke).Invoke($feature)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
