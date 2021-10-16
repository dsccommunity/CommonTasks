configuration SqlEndpoints {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Endpoints
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

    foreach ($endpoint in $Endpoints) 
    {
        if(-not $endpoint.InstanceName)
        {
            $endpoint.InstanceName = $DefaultInstanceName
        }

        if(-not $endpoint.Ensure)
        {
            $endpoint.Ensure = 'Present'
        }

        $executionName = "$($endpoint.InstanceName)_$($endpoint.EndpointName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlEndpoint -ExecutionName $executionName -Properties $endpoint -NoInvoke).Invoke($endpoint)
    }
}
