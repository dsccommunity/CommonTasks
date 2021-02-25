configuration WindowsEventForwarding
{
    Param (
        [Parameter(Mandatory)]
        [ValidateSet( 'Collector', 'Source')]
        [String]$NodeType,

        [Parameter()]
        [String]$CollectorName,

        [Parameter()]
        [Hashtable[]]$Subscriptions
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWindowsEventForwarding
   
    if( $NodeType -eq 'Collector' )
    {
        if( $null -eq $Subscriptions -or $Subscriptions.Count -lt 1 )
        {
            throw 'ERROR: A Collector node requires at least one subscription definition.'
        }

        xWEFCollector wefCollector
        {
            Ensure = "Present"
            Name   = "WindowsEventCollector"
        }

        foreach ($subscription in $Subscriptions)
        {   
            $subscription.DependsOn = '[xWEFCollector]wefCollector'

            $executionName = "wefsub_$($subscription.SubscriptionID -replace '[().:\s]', '')"
            (Get-DscSplattedResource -ResourceName xWEFSubscription  -ExecutionName $executionName -Properties $subscription -NoInvoke).Invoke($subscription)
        }
    }
    elseif( $NodeType -eq 'Source' )
    {
        if( $null -ne $Subscriptions -and $Subscriptions.Count -gt 0 )
        {
            throw 'ERROR: Subscription definitions are not supported on source nodes.'
        }

        if( [string]::IsNullOrWhiteSpace($CollectorName) )
        {
            throw 'ERROR: A CollectorName is required on source nodes.'
        }

        Group addCollectorToLocalEventLogReadersGroup
        {
            GroupName        = 'Event Log Readers'
            Ensure           = 'Present'
            MembersToInclude = "$CollectorName"
        }
    }
}
