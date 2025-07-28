# see https://github.com/dsccommunity/HyperVDsc
configuration HyperVReplica
{
    param
    (
        [Parameter()]
        [ValidateSet( 'Kerberos', 'Certificate', 'CertificateAndKerberos' )]
        [String]
        $AllowedAuthenticationType,

        [Parameter()]
        [Int32]
        $CertificateAuthenticationPort = 0,

        [Parameter()]
        [String]
        $CertificateThumbprint,

        [Parameter()]
        [String]
        $DefaultStorageLocation,

        [Parameter()]
        [Int32]
        $KerberosAuthenticationPort = 0,

        [Parameter()]
        [String]
        $MonitoringInterval,

        [Parameter()]
        [String]
        $MonitoringStartTime,

        [Parameter()]
        [Bool]
        $ReplicationAllowedFromAnyServer = $False,

        [Parameter()]
        [Hashtable[]]
        $VMMachines
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Script 'HyperVReplicationServer'
    {
        TestScript = {
            [boolean]$status = $false

            $repSrv = Get-VMReplicationServer -ErrorAction SilentlyContinue

            if ( $null -ne $repSrv )
            {
                if ( $repSrv.ReplicationEnabled )
                {
                    $status = $true

                    if ( -not [string]::IsNullOrWhiteSpace( $using:AllowedAuthenticationType ) -and $repSrv.AllowedAuthenticationType -ne $using:AllowedAuthenticationType )
                    {
                        Write-Verbose "AllowedAuthenticationType is $($repSrv.AllowedAuthenticationType) -> expected: $using:AllowedAuthenticationType"
                        $status = $false
                    }

                    if ( $using:CertificateAuthenticationPort -gt 0 -and $using:CertificateAuthenticationPort -ne $repSrv.CertificateAuthenticationPort )
                    {
                        Write-Verbose "CertificateAuthenticationPort is $($repSrv.CertificateAuthenticationPort) -> expected: $using:CertificateAuthenticationPort"
                        $status = $false
                    }

                    if ( -not [string]::IsNullOrWhiteSpace( $using:CertificateThumbprint ) -and $using:CertificateThumbprint -ne $repSrv.CertificateThumbprint )
                    {
                        Write-Verbose "CertificateThumbprint is $($repSrv.CertificateThumbprint) -> expected: $using:CertificateThumbprint"
                        $status = $false
                    }

                    if ( -not [string]::IsNullOrWhiteSpace( $using:DefaultStorageLocation ) -and $using:DefaultStorageLocation -ne $repSrv.DefaultStorageLocation )
                    {
                        Write-Verbose "DefaultStorageLocation is $($repSrv.DefaultStorageLocation) -> expected: $using:DefaultStorageLocation"
                        $status = $false
                    }

                    if ( $using:KerberosAuthenticationPort -gt 0 -and $using:KerberosAuthenticationPort -ne $repSrv.KerberosAuthenticationPort )
                    {
                        Write-Verbose "KerberosAuthenticationPort is $($repSrv.KerberosAuthenticationPort) -> expected: $using:KerberosAuthenticationPort"
                        $status = $false
                    }

                    if ( -not [string]::IsNullOrWhiteSpace( $using:MonitoringInterval ) -and $using:MonitoringInterval -ne $repSrv.MonitoringInterval )
                    {
                        Write-Verbose "MonitoringInterval is $($repSrv.MonitoringInterval) -> expected: $using:MonitoringInterval"
                        $status = $false
                    }

                    if ( -not [string]::IsNullOrWhiteSpace( $using:MonitoringStartTime ) -and $using:MonitoringStartTime -ne $repSrv.MonitoringStartTime )
                    {
                        Write-Verbose "MonitoringStartTime is $($repSrv.MonitoringStartTime) -> expected: $using:MonitoringStartTime"
                        $status = $false
                    }

                    if ( $using:ReplicationAllowedFromAnyServer -ne $repSrv.ReplicationAllowedFromAnyServer )
                    {
                        Write-Verbose "ReplicationAllowedFromAnyServer is $($repSrv.ReplicationAllowedFromAnyServer) -> expected: $using:ReplicationAllowedFromAnyServer"
                        $status = $false
                    }
                }
                else
                {
                    Write-Verbose 'VM Replication is not enabled.'
                }
            }

            return $status
        }
        SetScript  = {
            $params = @{
                ReplicationEnabled              = $True
                ReplicationAllowedFromAnyServer = $using:ReplicationAllowedFromAnyServer
            }
            if ( -not [string]::IsNullOrWhiteSpace( $using:AllowedAuthenticationType ) )
            {
                $params.AllowedAuthenticationType = $using:AllowedAuthenticationType
            }
            if ( $using:CertificateAuthenticationPort -gt 0 )
            {
                $params.CertificateAuthenticationPort = $using:CertificateAuthenticationPort
            }
            if ( -not [string]::IsNullOrWhiteSpace( $using:CertificateThumbprint ) )
            {
                $params.CertificateThumbprint = $using:CertificateThumbprint
            }
            if ( -not [string]::IsNullOrWhiteSpace( $using:DefaultStorageLocation ) )
            {
                $params.DefaultStorageLocation = $using:DefaultStorageLocation
            }
            if ( $using:KerberosAuthenticationPort -gt 0 )
            {
                $params.KerberosAuthenticationPort = $using:KerberosAuthenticationPort
            }
            if ( -not [string]::IsNullOrWhiteSpace( $using:MonitoringInterval ) )
            {
                $params.MonitoringInterval = $using:MonitoringInterval
            }
            if ( -not [string]::IsNullOrWhiteSpace( $using:MonitoringStartTime ) )
            {
                $params.MonitoringStartTime = $using:MonitoringStartTime
            }

            Write-Verbose "Set-VMReplicationServer with:`n $($s=''; $params.GetEnumerator() | ForEach-Object { $s+="$($_.Name)='$($_.Value)'  " }; $s)"
            Set-VMReplicationServer @params
        }
        GetScript  = { return `
            @{
                result = 'N/A'
            }
        }
    }

    if ( $null -ne $VMMachines )
    {
        foreach ($vmDef in $VMMachines)
        {
            if ( [string]::IsNullOrWhiteSpace( $vmDef.Name ) -or
                [string]::IsNullOrWhiteSpace( $vmDef.ReplicaServerName ) -or
                [string]::IsNullOrWhiteSpace( $vmDef.ReplicaServerPort ) -or
                [string]::IsNullOrWhiteSpace( $vmDef.AuthenticationType ) )
            {
                throw "ERROR: VM '$($vmDef.Name)': Missing mandatory parameters 'Name', 'ReplicaServerName', 'ReplicaServerPort' or 'AuthenticationType'."
            }

            $execName = "HyperVReplica_$($vmDef.Name)" -replace '[\s(){}/\\:-]', '_'

            Script $execName
            {
                TestScript = {
                    [boolean]$status = $false

                    $vmRep = Get-VMReplication -VMName $using:vmDef.Name -ErrorAction SilentlyContinue

                    if ( $null -ne $vmRep )
                    {
                        $status = $true

                        if ( (-not [string]::IsNullOrWhiteSpace( $using:vmDef.CompressionEnabled ) -and $vmRep.CompressionEnabled -ne $using:vmDef.CompressionEnabled) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.ReplicateHostKvpItems ) -and $vmRep.ReplicateHostKvpItems -ne $using:vmDef.ReplicateHostKvpItems) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.BypassProxyServer ) -and $vmRep.BypassProxyServer -ne $using:vmDef.BypassProxyServer) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.VSSSnapshotFrequencyHour ) -and $vmRep.VSSSnapshotFrequencyHour -ne $using:vmDef.VSSSnapshotFrequencyHour) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.RecoveryHistory ) -and $vmRep.RecoveryHistory -ne $using:vmDef.RecoveryHistory) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.ReplicationFrequencySec ) -and $vmRep.ReplicationFrequencySec -ne $using:vmDef.ReplicationFrequencySec) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeEnabled ) -and $vmRep.AutoResynchronizeEnabled -ne $using:vmDef.AutoResynchronizeEnabled) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeIntervalStart ) -and $vmRep.AutoResynchronizeIntervalStart -ne $using:vmDef.AutoResynchronizeIntervalStart) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeIntervalEnd ) -and $vmRep.AutoResynchronizeIntervalEnd -ne $using:vmDef.AutoResynchronizeIntervalEnd) -or
                            (-not [string]::IsNullOrWhiteSpace( $using:vmDef.EnableWriteOrderPreservationAcrossDisks ) -and $vmRep.EnableWriteOrderPreservationAcrossDisks -ne $using:vmDef.EnableWriteOrderPreservationAcrossDisks) )
                        {
                            Write-Verbose 'Optional replication parameters are diffent.'
                            $status = $false
                        }
                    }
                    else
                    {
                        Write-Verbose "Replication of VM '$($using:vmDef.Name)' is not enabled."
                    }

                    return $status
                }
                SetScript  = {
                    $params = @{
                        VMName = $using:vmDef.Name
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.CompressionEnabled ) )
                    {
                        $params.CompressionEnabled = $using:vmDef.CompressionEnabled
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.ReplicateHostKvpItems ) )
                    {
                        $params.ReplicateHostKvpItems = $using:vmDef.ReplicateHostKvpItems
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.BypassProxyServer ) )
                    {
                        $params.BypassProxyServer = $using:vmDef.BypassProxyServer
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.VSSSnapshotFrequencyHour ) )
                    {
                        $params.VSSSnapshotFrequencyHour = $using:vmDef.VSSSnapshotFrequencyHour
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.RecoveryHistory ) )
                    {
                        $params.RecoveryHistory = $using:vmDef.RecoveryHistory
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.ReplicationFrequencySec ) )
                    {
                        $params.ReplicationFrequencySec = $using:vmDef.ReplicationFrequencySec
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeEnabled ) )
                    {
                        $params.AutoResynchronizeEnabled = $using:vmDef.AutoResynchronizeEnabled
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeIntervalStart ) )
                    {
                        $params.AutoResynchronizeIntervalStart = $using:vmDef.AutoResynchronizeIntervalStart
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.AutoResynchronizeIntervalEnd ) )
                    {
                        $params.AutoResynchronizeIntervalEnd = $using:vmDef.AutoResynchronizeIntervalEnd
                    }
                    if ( -not [string]::IsNullOrWhiteSpace( $using:vmDef.EnableWriteOrderPreservationAcrossDisks ) )
                    {
                        $params.EnableWriteOrderPreservationAcrossDisks = $using:vmDef.EnableWriteOrderPreservationAcrossDisks
                    }

                    $vmRep = Get-VMReplication -VMName $using:vmDef.Name -ErrorAction SilentlyContinue

                    if ( $null -eq $vmRep )
                    {
                        $params.ReplicaServerName = $using:vmDef.ReplicaServerName
                        $params.ReplicaServerPort = $using:vmDef.ReplicaServerPort
                        $params.AuthenticationType = $using:vmDef.AuthenticationType
                        if ( -not [string]::IsNullOrWhiteSpace( $using:CertificateThumbprint ) )
                        {
                            $params.CertificateThumbprint = $using:CertificateThumbprint
                        }

                        Write-Verbose "Enable-VMReplication with:`n $($s=''; $params.GetEnumerator() | ForEach-Object { $s+="$($_.Name)='$($_.Value)'  " }; $s)"
                        Enable-VMReplication @params
                    }
                    else
                    {
                        Write-Verbose "Set-VMReplication with:`n $($s=''; $params.GetEnumerator() | ForEach-Object { $s+="$($_.Name)='$($_.Value)'  " }; $s)"
                        Set-VMReplication @params
                    }
                }
                GetScript  = { return `
                    @{
                        result = 'N/A'
                    }
                }
            }
        }
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
