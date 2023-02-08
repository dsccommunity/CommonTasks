configuration DnsServerCNameRecords
{
    param
    (
        [Parameter()]
        [Hashtable[]]
        $Records
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    [boolean]$dnsServerInstalled = $false

    if ($null -ne $Records)
    {
        foreach ($record in $Records)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $record = @{} + $record

            if (-not $record.ContainsKey('Ensure'))
            {
                $record.Ensure = 'Present'
            }

            # install DNS server if DNS record shall be set on a local DNS server
            if (-not $record.ContainsKey('DnsServer') -or $record.DnsServer -eq 'localhost')
            {
                if ($dnsServerInstalled -eq $false)
                {
                    WindowsFeature DNSServer
                    {
                        Name   = 'DNS'
                        Ensure = 'Present'
                    }

                    $dnsServerInstalled = $true
                }

                $record.DependsOn = '[WindowsFeature]DNSServer'
            }

            $executionName = "dnsrecord_$("$($record.Name)_$($record.ZoneName)_$($record.HostNameAlias)" -replace '[()-.:\s]', '_')"

            (Get-DscSplattedResource -ResourceName DnsRecordCname -ExecutionName $executionName -Properties $record -NoInvoke).Invoke($record)
        }
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
