configuration ExchangeMailboxDatabaseCopies {
    param (
        [Parameter(Mandatory)]
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
    Import-DscResource -Module xExchange

    foreach ($item in $Items) {

        $waitResourceId = "WaitForDB_$($item.Identity)"
        xExchWaitForMailboxDatabase $waitResourceId
        {
            Identity   = $item.Identity
            Credential = $item.Credential
        }

        $item.MailboxServer = $Node.NodeName
        $item.DependsOn = "[xExchWaitForMailboxDatabase]$waitResourceId"

        $executionName = $item.Identity
        (Get-DscSplattedResource -ResourceName xExchMailboxDatabaseCopy -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
