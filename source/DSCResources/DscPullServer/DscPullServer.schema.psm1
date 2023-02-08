configuration DscPullServer
{
    param (
        [Parameter()]
        [string]
        $CertificateThumbPrint = 'AllowUnencryptedTraffic',

        [Parameter()]
        [uint16]
        $Port = 8080,

        [Parameter()]
        [string]
        $EndpointName = 'PSDSCPullServer',

        [Parameter()]
        [string]
        $PhysicalPath = "$env:SystemDrive\inetpub\PSDSCPullServer",

        [Parameter()]
        [bool]
        $UseSecurityBestPractices = $false
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    xDscWebService PSDSCPullServer
    {
        Ensure                   = 'Present'
        EndpointName             = $EndpointName
        Port                     = $Port
        PhysicalPath             = $PhysicalPath
        CertificateThumbPrint    = $CertificateThumbPrint
        ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
        ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
        State                    = 'Started'
        UseSecurityBestPractices = $UseSecurityBestPractices
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
