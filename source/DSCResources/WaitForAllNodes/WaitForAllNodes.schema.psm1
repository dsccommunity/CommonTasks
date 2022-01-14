configuration WaitForAllNodes {
    param (
        [Parameter()]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    <#
    NodeName = [string[]]
    ResourceName = [string]
    [DependsOn = [string[]]]
    [PsDscRunAsCredential = [PSCredential]]
    [RetryCount = [UInt32]]
    [RetryIntervalSec = [UInt64]]
    [ThrottleLimit = [UInt32]]
    #>

    foreach ($item in $items)
    {
        $executionName = $item.ResourceName

        (Get-DscSplattedResource -ResourceName WaitForAll -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

}
