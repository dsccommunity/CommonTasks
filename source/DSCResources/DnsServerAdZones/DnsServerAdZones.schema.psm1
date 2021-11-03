configuration DnsServerAdZones
{
    param
    (
        [hashtable[]]
        $AdZones,

        [pscredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DnsServerDsc

    foreach ($adZone in $AdZones) {
        if (-not $adZone.ContainsKey('Ensure')) {
            $adZone.Ensure = 'Present'
        }

        if ($DomainCredential) {
            $adZone.Credential = $DomainCredential
        }

        $executionName = "$($node.Name)_$($adZone.Name)"
        (Get-DscSplattedResource -ResourceName DnsServerADZone -ExecutionName $executionName -Properties $adZone -NoInvoke).Invoke($adZone)
    }
}
