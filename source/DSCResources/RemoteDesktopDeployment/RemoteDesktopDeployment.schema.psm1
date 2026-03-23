configuration RemoteDesktopDeployment
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string]
        $WebAccess,

        [Parameter(Mandatory = $true)]
        [string[]]
        $SessionHosts,

        [Parameter()]
        [hashtable[]]
        $Gateways
    )

    Import-DscResource -ModuleName RemoteDesktopServicesDsc

    RDSessionDeployment RDS
    {
        ConnectionBroker = $ConnectionBroker
        WebAccessServer  = $WebAccess
        SessionHost      = $SessionHosts
    }

    # foreach ($gateway in $Gateways)
    # {
    #     $executionName = "rdsgw_$($gateway.GatewayServer -replace '[().:\s]', '')"

    #     (Get-DscSplattedResource -ResourceName xRDSessionDeployment -ExecutionName $executionName -Properties $gateway -NoInvoke).Invoke($gateway)
    # }
}
