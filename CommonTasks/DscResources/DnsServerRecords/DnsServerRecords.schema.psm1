configuration DnsServerRecords
{
    param
    (
        [Parameter()]
        [Hashtable[]]
        $Records,

        [Parameter()]
        [Hashtable[]]
        $MxRecords
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    [boolean]$dnsServerInstalled = $false

    if( $null -ne $Records )
    {
        foreach ($dnsRecord in $Records)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $dnsRecord = @{}+$dnsRecord

            if (-not $dnsRecord.ContainsKey('Ensure'))
            {
                $dnsRecord.Ensure = 'Present'
            }

            # install DNS server if DNS record shall be set on a local DNS server
            if (-not $dnsRecord.ContainsKey('DnsServer') -or $dnsRecord.DnsServer -eq 'localhost')
            {
                if( $dnsServerInstalled -eq $false )
                {
                    WindowsFeature DNSServer
                    {
                        Name   = 'DNS'
                        Ensure = 'Present'
                    }

                    $dnsServerInstalled = $true
                }

                $dnsRecord.DependsOn = '[WindowsFeature]DNSServer'
            }

            $executionName = "dnsrecord_$("$($dnsRecord.Name)_$($dnsRecord.Zone)_$($dnsRecord.Target)" -replace '[()-.:\s]', '_')"

            (Get-DscSplattedResource -ResourceName xDnsRecord -ExecutionName $executionName -Properties $dnsRecord -NoInvoke).Invoke($dnsRecord)
        }
    }

    if( $null -ne $MxRecords )
    {
        foreach ($mxRecord in $MxRecords)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $mxRecord = @{}+$mxRecord

            if (-not $mxRecord.ContainsKey('Ensure'))
            {
                $mxRecord.Ensure = 'Present'
            }

            # install DNS server if DNS record shall be set on a local DNS server
            if (-not $mxRecord.ContainsKey('DnsServer') -or $mxRecord.DnsServer -eq 'localhost')
            {
                if( $dnsServerInstalled -eq $false )
                {
                    WindowsFeature DNSServer
                    {
                        Name   = 'DNS'
                        Ensure = 'Present'
                    }

                    $dnsServerInstalled = $true
                }

                $mxRecord.DependsOn = '[WindowsFeature]DNSServer'
            }

            $executionName = "dnsmxrecord_$("$($mxRecord.Name)_$($mxRecord.Zone)_$($mxRecord.Target)" -replace '[()-.:\s]', '_')"

            (Get-DscSplattedResource -ResourceName xDnsRecordMx -ExecutionName $executionName -Properties $mxRecord -NoInvoke).Invoke($mxRecord)
        }
    }
}
