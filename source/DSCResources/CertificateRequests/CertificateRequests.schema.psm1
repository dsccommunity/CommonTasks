configuration CertificateRequests
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Requests
    )

    <#
        CertReq [String] #ResourceName
        {
            FriendlyName = [string]
            Subject = [string]
            [AutoRenew = [bool]]
            [CARootName = [string]]
            [CAServerFQDN = [string]]
            [CAType = [string]]
            [CepURL = [string]]
            [CertificateTemplate = [string]]
            [CesURL = [string]]
            [Credential = [PSCredential]]
            [DependsOn = [string[]]]
            [Exportable = [bool]]
            [KeyLength = [string]{ 1024 | 192 | 2048 | 224 | 256 | 384 | 4096 | 521 | 8192 }]
            [KeyType = [string]{ ECDH | RSA }]
            [KeyUsage = [string]]
            [OID = [string]]
            [ProviderName = [string]]
            [PsDscRunAsCredential = [PSCredential]]
            [RequestType = [string]{ CMC | PKCS10 }]
            [SubjectAltName = [string]]
            [UseMachineContext = [bool]]
        }
    #>

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module CertificateDsc

    $waitForAdcs = [System.Collections.Generic.List[string]]::new()

    foreach ($request in $Requests)
    {
        if ($null -ne $request.CAServerFqdn -and -not $waitForAdcs.Contains($request.CAServerFqdn))
        {
            WaitForCertificateServices "WaitForADCS$($request.CARootName -replace '[\s(){}/\\:=-]', '_')"
            {
                RetryIntervalSeconds = 20
                RetryCount           = 5
                CAServerFQDN         = $request.CAServerFqdn
                CARootName           = $request.CARootName
            }
            $null = $waitForAdcs.Add($request.CAServerFqdn)
        }

        $request.DependsOn = "[WaitForCertificateServices]WaitForADCS$($request.CARootName -replace '[\s(){}/\\:=-]', '_')"
        $executionName = "req_$($request.FriendlyName)_$($request.Subject)" -replace '[\s(){}/\\:=\.-]', '_'
        (Get-DscSplattedResource -ResourceName CertReq -ExecutionName $executionName -Properties $request -NoInvoke).Invoke($request)
    }
}
