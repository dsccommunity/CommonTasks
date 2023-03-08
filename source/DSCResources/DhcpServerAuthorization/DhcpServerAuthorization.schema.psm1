# see https://github.com/dsccommunity/xDhcpServer
configuration DhcpServerAuthorization
{
    param
    (
        [Parameter()]
        [ValidateSet( 'Present', 'Absent' )]
        [string] $Ensure = 'Present',

        [Parameter()]
        [string] $DnsName,

        [Parameter()]
        [string] $IpAddress
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xDhcpServer

    WindowsFeature DHCPServerTools
    {
        Name   = 'RSAT-DHCP'
        Ensure = 'Present'
    }

    xDhcpServerAuthorization DHCPServerAuthorization
    {
        IsSingleInstance = 'Yes'
        DnsName          = $DnsName
        IpAddress        = $IpAddress
        Ensure           = $Ensure
        DependsOn        = '[WindowsFeature]DHCPServerTools'
    }
}
