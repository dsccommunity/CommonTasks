configuration DscPullServerSql
{
    param (
        [Parameter()]
        [string]$CertificateThumbPrint = 'AllowUnencryptedTraffic',

        [Parameter()]
        [uint16]
        $Port = 8080,

        [Parameter(Mandatory)]
        [string]$RegistrationKey,

        [Parameter(Mandatory)]
        [string]$SqlServer,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter()]
        [string]
        $EndpointName = 'PSDSCPullServer',

        [Parameter()]
        [string]
        $PhysicalPath = "$env:SystemDrive\inetpub\PSDSCPullServer",

        [Parameter()]
        [string]
        $ModulePath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules",

        [Parameter()]
        [string]
        $ConfigurationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration",

        [Parameter()]
        [bool]
        $UseSecurityBestPractices = $false
    )

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration, PSDesiredStateConfiguration, xWebAdministration

    WindowsFeature DSCServiceFeature {
        Ensure = 'Present'
        Name   = 'DSC-Service'
    }

    $sqlConnectionString = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=$DatabaseName;Data Source=$SqlServer"

    xDscWebService PSDSCPullServer {
        Ensure                       = 'Present'
        EndpointName                 = 'PSDSCPullServer'
        Port                         = $Port
        PhysicalPath                 = $PhysicalPath
        CertificateThumbPrint        = $CertificateThumbPrint
        ModulePath                   = $ModulePath
        ConfigurationPath            = $ConfigurationPath
        State                        = 'Started'
        UseSecurityBestPractices     = $UseSecurityBestPractices
        AcceptSelfSignedCertificates = $true
        SqlProvider                  = $true
        SqlConnectionString          = $sqlConnectionString
        ApplicationPoolName          = 'PSWS'
        DependsOn                    = '[WindowsFeature]DSCServiceFeature'

    }

    File RegistrationKeyFile {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
        Contents        = $RegistrationKey
    }

    xWebConfigKeyValue CorrectDBProvider {
        ConfigSection = 'AppSettings'
        Key           = 'dbprovider'
        Value         = 'System.Data.OleDb'
        WebsitePath   = 'IIS:\sites\PSDSCPullServer'
        DependsOn     = '[xDSCWebService]PSDSCPullServer'
    }
}
