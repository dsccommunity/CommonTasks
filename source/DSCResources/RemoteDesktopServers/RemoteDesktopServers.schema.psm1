configuration RemoteDesktopServers
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Servers
    )

    <#
    @{
        Role = [string]{ RDS-Connection-Broker | RDS-Gateway | RDS-Licensing | RDS-RD-Server | RDS-Virtualization | RDS-Web-Access }
        Server = [string]
        [ConnectionBroker = [string]]
        [DependsOn = [string[]]]
        [GatewayExternalFqdn = [string]]
        [PsDscRunAsCredential = [PSCredential]]
    }
    #>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xRemoteDesktopSessionHost

    foreach ($server in $Servers)
    {
        $server = @{} + $server

        $executionName = "RDSRole_$($server.Role)_on_$($server.Server)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xRDServer -ExecutionName $executionName -Properties $server -NoInvoke).Invoke($server)
    }
}
