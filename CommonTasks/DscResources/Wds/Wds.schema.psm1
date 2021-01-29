configuration Wds
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $RemInstPath,

        [Parameter(Mandatory=$false)]
        [pscredential]
        $RunAsUser = $null,

        [Parameter(Mandatory=$false)]
        [boolean]
        $UseExistingDhcpScope = $false,

        [Parameter(Mandatory=$false)]
        [string]
        $ScopeStart,

        [Parameter(Mandatory=$false)]
        [string]
        $ScopeEnd,

        [Parameter(Mandatory=$false)]
        [string]
        $ScopeId,

        [Parameter(Mandatory=$false)]
        [string]
        $SubnetMask
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WdsDsc
    Import-DscResource -ModuleName xDhcpServer

    if( $UseExistingDhcpScope -eq $false )
    {
        WindowsFeature dhcpFeature
        {
            Name   = 'DHCP'
            IncludeAllSubFeature = $true
            Ensure = 'Present'
        }

        xDhcpServerScope clientScope
        {
            ScopeId      = $ScopeId
            IPStartRange = $ScopeStart
            IPEndRange   = $ScopeEnd
            SubnetMask   = $SubnetMask
            Name         = 'WdsClients'
            Ensure       = 'Present'
            DependsOn    = '[WindowsFeature]dhcpFeature'
        }
    }
    else
    {
        if( -not [string]::IsNullOrWhiteSpace($ScopeId) -or
            -not [string]::IsNullOrWhiteSpace($ScopeStart) -or
            -not [string]::IsNullOrWhiteSpace($ScopeEnd) -or
            -not [string]::IsNullOrWhiteSpace($SubnetMask) )
        {
            throw "ERROR: if 'UseExistingDhcpScope' is set to 'true' all DHCP scope parameters shall be empty."
        }
    }

    WindowsFeature wdsFeature
    {
        Name                 = 'WDS'
        IncludeAllSubFeature = $true
        Ensure               = 'Present'
    }

    WdsInitialize wdsInit
    {
        IsSingleInstance     = 'Yes'
        PsDscRunAsCredential = $runAsCred
        Path                 = $RemInstPath
        Authorized           = $true
        Standalone           = $false
        Ensure               = 'Present'
        DependsOn            = '[WindowsFeature]wdsFeature'
    }
}
