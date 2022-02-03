configuration MmaAgent
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $WorkspaceId,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $WorkspaceKey,

        [Parameter()]
        [string]
        $ProxyUri,

        [Parameter()]
        [pscredential]
        $ProxyCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName MmaDsc

    $PSBoundParameters.Remove('InstanceName')
    $PSBoundParameters.Remove('DependsOn')

    (Get-DscSplattedResource -ResourceName WorkspaceConfiguration -ExecutionName MmaConfig -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)
}
