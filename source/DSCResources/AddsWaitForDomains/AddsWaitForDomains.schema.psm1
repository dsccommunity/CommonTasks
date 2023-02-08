configuration AddsWaitForDomains
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Domains
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    foreach ($domain in $Domains)
    {
        $executionName = $domain.DomainName
        (Get-DscSplattedResource -ResourceName WaitForADDomain -ExecutionName $executionName -Properties $domain -NoInvoke).Invoke($domain)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
