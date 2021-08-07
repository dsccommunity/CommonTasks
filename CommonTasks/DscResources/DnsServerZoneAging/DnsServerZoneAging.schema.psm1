configuration DnsServerZoneAging
{
    param
    (
        [Parameter(Mandatory)]
        [Hashtable[]]
        $Zones
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    foreach ($zone in $Zones)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $zone = @{}+$zone

        if (-not $zone.ContainsKey('Enabled'))
        {
            $zone.Enabled = $True
        }

        $executionName = "dnszoneaging_$($zone.Name -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName xDnsServerZoneAging -ExecutionName $executionName -Properties $zone -NoInvoke).Invoke($zone)
    }
}
