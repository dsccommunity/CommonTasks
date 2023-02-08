configuration CertificateExports {
    param
    (
        [Parameter()]
        [Hashtable[]]
        $Certificates
    )
    
    $curPSModulePath = $env:PSModulePath

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module CertificateDsc

    foreach ($cert in $Certificates)
    {
        $executionName = "certexport_$($cert.Path)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName CertificateExport -ExecutionName $executionName -Properties $cert -NoInvoke).Invoke($cert)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
