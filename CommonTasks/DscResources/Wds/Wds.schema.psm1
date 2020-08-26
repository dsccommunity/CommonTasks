configuration Wds
{
    param
    (
        [string]
        $RemInstPath,

        [pscredential]
        $RunAsUser,

        [string]
        $ScopeStart,

        [string]
        $ScopeEnd,

        [string]
        $ScopeId,

        [string]
        $SubnetMask
    )

    Import-DscResource -ModuleName WdsDsc
    Import-DscResource -ModuleName xDhcpServer

    xDhcpServerScope clientScope
    {
        ScopeId      = $ScopeId
        IPStartRange = $ScopeStart
        IPEndRange   = $ScopeEnd
        SubnetMask   = $SubnetMask
        Name         = 'WdsClients'
    }

    WdsInitialize wdsInit
    {
        DependsOn = '[xDhcpServerScope]clientScope'
        IsSingleInstance     = 'Yes'
        PsDscRunAsCredential = $runAsCred
        Path                 = $RemInstPath
        Authorized           = $true
        Standalone           = $false
        Ensure               = 'Present'
    }
}
