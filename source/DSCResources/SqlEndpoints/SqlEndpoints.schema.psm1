configuration SqlEndpoints {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
    )

    <#
    EndpointName = [string]
    EndpointType = [string]{ DatabaseMirroring | ServiceBroker }
    InstanceName = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [IpAddress = [string]]
    [IsMessageForwardingEnabled = [bool]]
    [MessageForwardingSize = [UInt32]]
    [Owner = [string]]
    [Port = [UInt16]]
    [PsDscRunAsCredential = [PSCredential]]
    [ServerName = [string]]
    [State = [string]{ Disabled | Started | Stopped }]
    #>

    Import-DscResource -ModuleName SqlServerDsc

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if (-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.EndpointName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlEndpoint -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
