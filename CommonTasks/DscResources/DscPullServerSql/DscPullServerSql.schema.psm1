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
        [string]$SqlServer = 'localhost',

        [Parameter(Mandatory)]
        [string]$DatabaseName = 'DSC',

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

    $regKeyPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"

    File RegistrationKeyFile {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = $regKeyPath
        Contents        = $RegistrationKey
    }

    $sqlConnectionString = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=$DatabaseName;Data Source=$SqlServer"

    xDscWebService PSDSCPullServer {
        Ensure                       = 'Present'
        EndpointName                 = $EndpointName
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
        ConfigureFirewall            = $false
        ApplicationPoolName          = 'PSWS'
        RegistrationKeyPath          = $regKeyPath
        DependsOn                    = '[WindowsFeature]DSCServiceFeature'
    }

    xWebConfigKeyValue CorrectDBProvider {
        ConfigSection = 'AppSettings'
        Key           = 'dbprovider'
        Value         = 'System.Data.OleDb'
        WebsitePath   = 'IIS:\sites\PSDSCPullServer'
        DependsOn     = '[xDSCWebService]PSDSCPullServer'
    }
}
