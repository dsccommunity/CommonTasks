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
    
    foreach ($dnsRecord in $Records)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $dnsRecord = @{}+$dnsRecord

        if (-not $dnsRecord.ContainsKey('Ensure'))
        {
            $dnsRecord.Ensure = 'Present'
        }

        $executionName = "dnsrecord_$("$($dnsRecord.Name)_$($dnsRecord.Zone)" -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName xDnsRecord -ExecutionName $executionName -Properties $dnsRecord -NoInvoke).Invoke($dnsRecord)
    }
}
