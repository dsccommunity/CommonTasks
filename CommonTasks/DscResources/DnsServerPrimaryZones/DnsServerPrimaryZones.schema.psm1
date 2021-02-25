configuration DnsServerPrimaryZones
{
    param
    (
        [Parameter(Mandatory)]
        [Hashtable[]]
        $PrimaryZones
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDnsServer

    WindowsFeature DNSServer
    {
        Name   = 'DNS'
        Ensure = 'Present'
    }

    foreach ($primaryZone in $PrimaryZones)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $primaryZone = @{}+$primaryZone

        if (-not $primaryZone.ContainsKey('Ensure'))
        {
            $primaryZone.Ensure = 'Present'
        }

        $primaryZone.DependsOn = '[WindowsFeature]DNSServer'

        $executionName = "dnspzone_$($primaryZone.Name -replace '[()-.:\s]', '_')"

        (Get-DscSplattedResource -ResourceName xDnsServerPrimaryZone -ExecutionName $executionName -Properties $primaryZone -NoInvoke).Invoke($primaryZone)
    }
}
