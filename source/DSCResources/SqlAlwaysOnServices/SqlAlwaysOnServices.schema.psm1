configuration SqlAlwaysOnServices {
    param (
        [Parameter()]
        [string]
        $SqlInstanceName = 'MSSQLSERVER',

        [Parameter()]
        [int]
        $RestartTimeout,

        [Parameter()]
        [string]
        $ServerName,

        [Parameter()]
        [string]
        $Ensure
    )

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAlwaysOnService

    if (-not $PSBoundParameters.ContainsKey('Ensure'))
    {
        $PSBoundParameters.Add('Ensure', 'Present')
    }

    $PSBoundParameters.Remove('DependsOn')
    $PSBoundParameters.InstanceName = $SqlInstanceName
    $PSBoundParameters.Remove('SqlInstanceName')

    $executionName = "$($ServerName)_$($InstanceName)"
    (Get-DscSplattedResource -ResourceName SqlAlwaysOnService -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)

}
