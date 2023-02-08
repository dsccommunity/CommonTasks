configuration RemoteDesktopDeployment
{
    param
    (
        [Parameter(Mandatory = $true)]
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

    $curPSModulePath = $env:PSModulePath

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

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
