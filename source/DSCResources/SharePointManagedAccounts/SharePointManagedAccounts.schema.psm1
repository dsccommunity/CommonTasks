configuration SharePointManagedAccounts
{
    param (
        [Parameter()]
        [hashtable[]]
        $ManagedAccounts
    )

    <#
    AccountName = [string]
    [Account = [PSCredential]]
    [DependsOn = [string[]]]
    [EmailNotification = [UInt32]]
    [Ensure = [string]{ Absent | Present }]
    [InstallAccount = [PSCredential]]
    [PreExpireDays = [UInt32]]
    [PsDscRunAsCredential = [PSCredential]]
    [Schedule = [string]]
    #>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    foreach ($item in $ManagedAccounts)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.AccountName
        (Get-DscSplattedResource -ResourceName SPManagedAccount -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
