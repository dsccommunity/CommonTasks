configuration SqlAgentAlerts {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Alerts
    )

    <#
    DefaultInstanceName: MSSQLSERVER
    Alerts:
        - Name: 'Sev17' [String] (Mandatory)
          ServerName: 'TestServer' [String]
          InstanceName: 'MSSQLServer' [String]
          Severity: '17' [String]
        - Name: 'Msg825'
          ServerName: 'TestServer'
          InstanceName: 'MSSQLServer'
          MessageId: '825'
    #>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAgentAlert

    foreach ($alert in $Alerts)
    {
        if (-not $alert.InstanceName)
        {
            $alert.InstanceName = $DefaultInstanceName
        }

        $executionName = "SqlAgentAlert_$($alert.Servername)_$($alert.InstanceName)_$($alert.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlAgentAlert -ExecutionName $executionName -Properties $alert -NoInvoke).Invoke($alert)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
