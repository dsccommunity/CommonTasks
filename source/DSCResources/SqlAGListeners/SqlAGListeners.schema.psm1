configuration SqlAGListeners {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]$Values
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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlAGListener

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if (-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.AvailabilityGroup)_$($value.Name)"
        (Get-DscSplattedResource -ResourceName SqlAGListener -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
