configuration DnsServerZonesAging
{
    param
    (
        [Parameter(Mandatory)]
        [Hashtable[]]
        $Zones
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    foreach ($zone in $Zones)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $zone = @{}+$zone

        if (-not $zone.ContainsKey('Enabled'))
        {
            $zone.Enabled = $true
        }

        $executionName = "dnszoneaging_$($zone.Name -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName DnsServerZoneAging -ExecutionName $executionName -Properties $zone -NoInvoke).Invoke($zone)
    }
}
