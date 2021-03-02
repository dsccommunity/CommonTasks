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
        $UseSecurityBestPractices = $false,

        [Parameter()]
        [bool]
        $ConfigureFirewall = $false
    )
       
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    Import-DSCResource -ModuleName NetworkingDsc
    Import-DSCResource -ModuleName xWebAdministration

    [string]$applicationPoolName = 'DscPullSrvSqlPool'

    WindowsFeature DSCServiceFeature 
    {
        Ensure = 'Present'
        Name   = 'DSC-Service'
    }

    $regKeyPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"

    File RegistrationKeyFile 
    {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = $regKeyPath
        Contents        = $RegistrationKey
    }

    # Test-TargetResource with default ApplicationPool 'PSWS' doesn't work with xPSDesiredStateConfiguration 9.1.0
    xWebAppPool PSDSCPullServerPool
    {
        Ensure       = 'Present'
        Name         = $applicationPoolName
        IdentityType = 'NetworkService'
    }

    $sqlConnectionString = "Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=$DatabaseName;Data Source=$SqlServer"

    xDscWebService PSDSCPullServer 
    {
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
        ApplicationPoolName          = $applicationPoolName
        # don't use this parameter: https://github.com/dsccommunity/xPSDesiredStateConfiguration/issues/199
        # RegistrationKeyPath          = $regKeyPath
        DependsOn                    = '[WindowsFeature]DSCServiceFeature', '[xWebAppPool]PSDSCPullServerPool'
    }

    xWebConfigKeyValue CorrectDBProvider 
    {
        ConfigSection = 'AppSettings'
        Key           = 'dbprovider'
        Value         = 'System.Data.OleDb'
        WebsitePath   = "IIS:\sites\$EndpointName"
        DependsOn     = '[xDSCWebService]PSDSCPullServer'
    }

    if( $ConfigureFirewall -eq $true ) 
    {
        Firewall PSDSCPullServerRule
        {
            Ensure      = 'Present'
            Name        = "DSC_PullServer_$Port"
            DisplayName = "DSC PullServer $Port"
            Group       = 'DSC PullServer'
            Enabled     = $true
            Action      = 'Allow'
            Direction   = 'InBound'
            LocalPort   = $Port
            Protocol    = 'TCP'
            DependsOn   = '[xDscWebService]PSDSCPullServer'
        }        
    }
}
