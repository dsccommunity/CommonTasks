# see https://github.com/dsccommunity/DhcpServerDsc
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
    Import-DscResource -ModuleName DhcpServerDsc

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
