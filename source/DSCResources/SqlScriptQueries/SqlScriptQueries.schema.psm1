configuration SqlScriptQueries {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Queries
    )

    <#
    DefaultInstanceName = [string]
    Queries= [hashtable[]]
        InstanceName = [string]
        GetQuery = [string]
        TestQuery = [string]
        SetQuery = [string]
        ServerName  = [String] = (Get-ComputerName)
        Credential = [PSCredential]
        QueryTimeout = [UInt32]
        Variable = [String]
        DisableVariables = [Boolean]
    #>
    #Hashing Queries for unique Execution/Resourcename
    $HashClass = New-Object System.Security.Cryptography.SHA1Managed
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($query in $Queries)
    {
        if (-not $query.InstanceName)
        {
            $query.InstanceName = $DefaultInstanceName
        }

        $ByteString = [System.Text.Encoding]::UTF8.GetBytes(($query.ServerName+$query.InstanceName+$query.TestQuery+$query.SetQuery+$query.GetQuery))
        $hash = [System.BitConverter]::ToString($HashClass.ComputeHash($ByteString)) -replace '-',''
        $executionName = "SqlQuery_$($query.ServerName)_$($query.InstanceName)_$($hash)"
        (Get-DscSplattedResource -ResourceName SqlScriptQuery -ExecutionName $executionName -Properties $query -NoInvoke).Invoke($query)
    }
}
