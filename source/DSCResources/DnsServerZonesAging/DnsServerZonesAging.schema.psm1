configuration DnsServerZonesAging
{
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable[]]
        $Zones
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    foreach ($zone in $Zones)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $zone = @{} + $zone

        if (-not $zone.ContainsKey('Enabled'))
        {
            $zone.Enabled = $true
        }

        $executionName = "dnszoneaging_$($zone.Name -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName DnsServerZoneAging -ExecutionName $executionName -Properties $zone -NoInvoke).Invoke($zone)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
