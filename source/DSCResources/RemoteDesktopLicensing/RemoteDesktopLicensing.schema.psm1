configuration RemoteDesktopLicensing
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConnectionBroker,

        [Parameter()]
        [string]
        $LicenseServer = $Node.NodeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('PerUser', 'PerDevice', 'NotConfigured')]
        $LicenseMode
    )

    Import-DscResource -ModuleName RemoteDesktopServicesDsc

    RDServer RDSLicense
    {
        Role             = 'RDS-Licensing'
        Server           = $LicenseServer
        ConnectionBroker = $ConnectionBroker
    }

    RDLicenseConfiguration Licensing
    {
        DependsOn        = '[RDServer]RDSLicense'
        ConnectionBroker = $ConnectionBroker
        LicenseServer    = $LicenseServer
        LicenseMode      = $LicenseMode
    }
}
