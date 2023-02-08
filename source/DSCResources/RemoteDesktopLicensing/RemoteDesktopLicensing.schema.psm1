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
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        $LicenseMode
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName xRemoteDesktopSessionHost


    xRDServer RDSLicense
    {
        Role             = 'RDS-Licensing'
        Server           = $LicenseServer
        ConnectionBroker = $ConnectionBroker
    }

    xRDLicenseConfiguration Licensing
    {
        DependsOn        = '[xRDServer]RDSLicense'
        ConnectionBroker = $ConnectionBroker
        LicenseServer    = $LicenseServer
        LicenseMode      = $LicenseMode
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
