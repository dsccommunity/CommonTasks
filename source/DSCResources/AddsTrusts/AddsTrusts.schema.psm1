configuration AddsTrusts
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Trusts
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    $PSBoundParameters.Remove('InstanceName')
    $PSBoundParameters.Remove('DependsOn')

    foreach ($trust in $Trusts)
    {
        $waitFor = @{
            DomainName = $trust.TargetDomainName
        }
        if ($trust.TargetCredential)
        {
            $waitFor.Credential = $trust.TargetCredential
        }

        (Get-DscSplattedResource -ResourceName WaitForADDomain -ExecutionName $trust.TargetDomainName -Properties $waitFor -NoInvoke).Invoke($waitFor)

        $trust['DependsOn'] = "[WaitForADDomain]$($trust.TargetDomainName)"
        $executionName = "$($trust.SourceDomainName)-to-$($trust.TargetDomainName)".Replace('.', '-')
        (Get-DscSplattedResource -ResourceName ADDomainTrust -ExecutionName $executionName -Properties $trust -NoInvoke).Invoke($trust)
    }
}
