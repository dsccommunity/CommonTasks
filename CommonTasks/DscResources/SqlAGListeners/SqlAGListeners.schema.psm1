configuration SqlAGListeners {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Listeners
    )

    <#
    AvailabilityGroup = [string]
    InstanceName = [string]
    Name = [string]
    ServerName = [string]
    [DependsOn = [string[]]]
    [DHCP = [bool]]
    [Ensure = [string]{ Absent | Present }]
    [IpAddress = [string[]]]
    [Port = [UInt16]]
    [PsDscRunAsCredential = [PSCredential]]
    #>
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($listener in $Listeners)
    {
        if (-not $listener.InstanceName)
        {
            $listener.InstanceName = $DefaultInstanceName
        }

        if(-not $listener.Ensure)
        {
            $listener.Ensure = 'Present'
        }

        $executionName = "$($listener.InstanceName)_$($listener.AvailabilityGroup)_$($listener.Name)"
        (Get-DscSplattedResource -ResourceName SqlAGListener -ExecutionName $executionName -Properties $listener -NoInvoke).Invoke($listener)
    }
}
