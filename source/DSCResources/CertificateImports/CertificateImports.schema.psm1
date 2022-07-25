configuration CertificateImports
{
    param
    (
        [Parameter()]
        [Hashtable[]]
        $CertFiles,

        [Parameter()]
        [Hashtable[]]
        $PfxFiles
    )

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module CertificateDsc

    function EmbedFile
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
        param
        (
            [Parameter()]
            [Hashtable]
            $CertFile
        )

        if ($certFile.ContainsKey('EmbedFile'))
        {
            if ($certFile.EmbedFile -match '^\s*(True|1)\s*$')
            {
                if (-not (Test-Path -Path $certFile.Path))
                {
                    Write-Host "ERROR: Certificate file '$($certFile.Path)' not found. Current working directory is: $(Get-Location)" -ForegroundColor Red
                }
                else
                {
                    $certFilePath = Resolve-Path $certFile.Path
                    $certFile.Content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($certFilePath))
                    $certFile.Remove('Path')
                }
            }
            $certFile.Remove('EmbedFile')
        }
    }


    if ($null -ne $CertFiles)
    {
        foreach ($certFile in $CertFiles)
        {
            EmbedFile -CertFile $certFile

            $executionName = "cert_$($certFile.Thumbprint)_$($certFile.Location)_$($certFile.Store)" -replace '[\s(){}/\\:-]', '_'
            (Get-DscSplattedResource -ResourceName CertificateImport -ExecutionName $executionName -Properties $certFile -NoInvoke).Invoke($certFile)
        }
    }

    if ($null -ne $PfxFiles)
    {
        foreach ($pfxFile in $PfxFiles)
        {
            EmbedFile -CertFile $pfxFile

            $executionName = "pfx_$($pfxFile.Thumbprint)_$($pfxFile.Location)_$($pfxFile.Store)" -replace '[\s(){}/\\:-]', '_'
            (Get-DscSplattedResource -ResourceName PfxImport -ExecutionName $executionName -Properties $pfxFile -NoInvoke).Invoke($pfxFile)
        }
    }
}
