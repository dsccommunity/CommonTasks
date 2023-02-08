configuration AddsSiteLinks
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $SiteLinks
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    foreach ($siteLink in $SiteLinks)
    {
        if (-not $siteLink.ContainsKey('Ensure'))
        {
            $siteLink.Ensure = 'Present'
        }

        $executionName = $siteLink.Name
        (Get-DscSplattedResource -ResourceName ADReplicationSiteLink -ExecutionName $executionName -Properties $siteLink -NoInvoke).Invoke($siteLink)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
