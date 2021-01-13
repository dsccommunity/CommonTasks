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
    Import-DscResource -ModuleName xDnsServer

    foreach ($adZone in $AdZones) {
        if (-not $adZone.ContainsKey('Ensure')) {
            $adZone.Ensure = 'Present'
        }

        if ($DomainCredential) {
            $adZone.Credential = $DomainCredential
        }

        $executionName = "$($node.Name)_$($adZone.Name)"
        (Get-DscSplattedResource -ResourceName xDnsServerADZone -ExecutionName $executionName -Properties $adZone -NoInvoke).Invoke($adZone)
    }
}
