configuration DhcpServerOptions
{
    param
    (
        [hashtable[]]
        $ServerOptions
    )

<#
    AddressFamily = [string]{ IPv4 }
    OptionId = [UInt32]
    UserClass = [string]
    VendorClass = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    [Value = [string[]]]
#>

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    foreach ($serverOption in $ServerOptions) {
        if (-not $serverOption.ContainsKey('Ensure')) {
            $serverOption.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($serverOption.ScopeId)_$($serverOption.OptionId)"
        (Get-DscSplattedResource -ResourceName DhcpServerOptionValue -ExecutionName $executionName -Properties $serverOption -NoInvoke).Invoke($serverOption)
    }
}
