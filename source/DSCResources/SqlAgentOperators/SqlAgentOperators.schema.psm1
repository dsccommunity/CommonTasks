configuration SqlAgentOperators {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $AgentOperators
    )

    <#
    DefaultInstanceName: MSSQLSERVER [string]
    AgentOperators:
        - Name: 'DbaTeam' [string] Mandatory
          ServerName: 'TestServer' [string]
          InstanceName: 'MSSQLServer' [string]
          EmailAddress: 'dbateam@company.com' [string]
    #>

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAgentOperator

    foreach ($operator in $AgentOperators)
    {
        if (-not $operator.InstanceName)
        {
            $operator.InstanceName = $DefaultInstanceName
        }

        $executionName = "SqlAgentOperators_$($operator.ServerName)_$($operator.InstanceName)_$($operator.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlAgentOperator -ExecutionName $executionName -Properties $operator -NoInvoke).Invoke($operator)
    }
}
