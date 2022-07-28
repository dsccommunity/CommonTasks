configuration RemoteDesktopDeployment
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $ConnectionBroker,

        [Parameter()]
        [string]
        $WebAccess,

        [Parameter()]
        [string[]]
        $SessionHosts,

        [Parameter()]
        [hashtable[]]
        $Gateways
    )

    Import-DscResource -ModuleName xRemoteDesktopSessionHost


    xRDSessionDeployment RDS
    {
        ConnectionBroker = $ConnectionBroker
        WebAccessServer  = $WebAccess
        SessionHost      = $SessionHosts
    }

    foreach ($gateway in $Gateways)
    {
        $executionName = "rdsgw_$($gateway.GatewayServer -replace '[().:\s]', '')"

        (Get-DscSplattedResource -ResourceName xRDSessionDeployment -ExecutionName $executionName -Properties $gateway -NoInvoke).Invoke($gateway)
    }
}
