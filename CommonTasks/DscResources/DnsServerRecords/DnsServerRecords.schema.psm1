configuration DnsServerRecords
{
    param
    (
        [Parameter(Mandatory)]
        [Hashtable[]]
        $Records
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    [boolean]$dnsServerInstalled = $false

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

        $executionName = "dnsrecord_$("$($dnsRecord.Name)_$($dnsRecord.Zone)" -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName xDnsRecord -ExecutionName $executionName -Properties $dnsRecord -NoInvoke).Invoke($dnsRecord)
    }
}
