configuration RemoteDesktopCertificates
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Certificates
    )

    <#
        @{
            ConnectionBroker = [string]
            ImportPath = [string]
            Role = [string]{ RDGateway | RDPublishing | RDRedirector | RDWebAccess }
            [Credential = [PSCredential]]
            [DependsOn = [string[]]]
            [PsDscRunAsCredential = [PSCredential]]
        }
    #>
    Import-DscResource -ModuleName xRemoteDesktopSessionHost

    foreach ($certificate in $Certificates)
    {
        $executionName = "rdscert_$($certificate.ConnectionBroker)_$($certificate.Role)_$($certificate.ImportPath -replace '\W', '')"

        (Get-DscSplattedResource -ResourceName xRDCertificateConfiguration -ExecutionName $executionName -Properties $certificate -NoInvoke).Invoke($certificate)
    }
}
