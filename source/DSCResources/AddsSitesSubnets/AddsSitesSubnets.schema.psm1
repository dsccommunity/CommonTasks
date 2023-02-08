configuration AddsSitesSubnets
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Sites,

        [Parameter()]
        [hashtable[]]
        $Subnets
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    $siteDependencies = @()
    foreach ($site in $Sites)
    {
        $siteDependencies += "[ADReplicationSite]$($site.Name)"
        (Get-DscSplattedResource -ResourceName ADReplicationSite -ExecutionName $site.Name -Properties $site -NoInvoke).Invoke($site)
    }

    foreach ($subnet in $Subnets)
    {
        if ($siteDependencies.Count -gt 0)
        {
            $subnet.DependsOn = $siteDependencies
        }

        (Get-DscSplattedResource -ResourceName ADReplicationSubnet -ExecutionName $subnet.Name -Properties $subnet -NoInvoke).Invoke($subnet)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
