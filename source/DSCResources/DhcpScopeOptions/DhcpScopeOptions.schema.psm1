configuration DhcpScopeOptions
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $ScopeOptions
    )

    <#
    AddressFamily = [string]{ IPv4 }
    OptionId = [UInt32]
    ScopeId = [string]
    UserClass = [string]
    VendorClass = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    [Value = [string[]]]
#>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    foreach ($scopeOption in $ScopeOptions)
    {
        if (-not $scopeOption.ContainsKey('Ensure'))
        {
            $scopeOption.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($scopeOption.ScopeId)_$($scopeOption.OptionId)"
        (Get-DscSplattedResource -ResourceName DhcpScopeOptionValue  -ExecutionName $executionName -Properties $scopeOption -NoInvoke).Invoke($scopeOption)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
