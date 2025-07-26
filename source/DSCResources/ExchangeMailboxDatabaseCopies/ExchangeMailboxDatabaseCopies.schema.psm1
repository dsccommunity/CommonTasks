configuration ExchangeMailboxDatabaseCopies {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]$Items
    )

    <#
    Credential = [PSCredential]
    Identity = [string]
    MailboxServer = [string]
    [ActivationPreference = [UInt32]]
    [AdServerSettingsPreferredServer = [string]]
    [AllowServiceRestart = [bool]]
    [DependsOn = [string[]]]
    [DomainController = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [ReplayLagMaxDelay = [string]]
    [ReplayLagTime = [string]]
    [SeedingPostponed = [bool]]
    [TruncationLagTime = [string]]
    #>

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module ExchangeDsc

    foreach ($item in $Items)
    {
        $waitResourceId = "WaitForDB_$($item.Identity)"
        ExchWaitForMailboxDatabase $waitResourceId
        {
            Identity   = $item.Identity
            Credential = $item.Credential
        }

        $item.MailboxServer = $Node.NodeName
        $item.DependsOn = "[ExchWaitForMailboxDatabase]$waitResourceId"

        $executionName = $item.Identity
        (Get-DscSplattedResource -ResourceName ExchMailboxDatabaseCopy -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
