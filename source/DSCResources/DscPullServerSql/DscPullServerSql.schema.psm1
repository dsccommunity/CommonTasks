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
        WebsitePath   = "IIS:\sites\$EndpointName"
        ConfigSection = 'AppSettings'
        Key           = 'dbprovider'
        Value         = 'System.Data.OleDb'
        DependsOn     = '[xDSCWebService]PSDSCPullServer'
    }

    # Fix RequestEntityTooLarge (EventID 4260) Error
    # https://github.com/dsccommunity/xPSDesiredStateConfiguration/issues/354
    # https://docs.microsoft.com/de-de/archive/blogs/fieldcoding/broken-dsc-reporting-requestentitytoolarge-and-some-lcm-internals

    [string]$bufferSize = 256MB

    Script WebConfigBindingMessageSize
    {
        TestScript = {
            $webConfigPath = "$using:PhysicalPath\web.config"

            if( -not (Test-Path -Path $webConfigPath) )
            {
                Write-Verbose "Configuration file '$webConfigPath' not found."  
                return $false
            }

            Write-Verbose "Reading configuration file '$webConfigPath'."  
            
            [xml]$webConfigXml = Get-Content -Path $webConfigPath

            # read bindings
            $bindingNode = $webConfigXml.SelectSingleNode('/configuration/system.serviceModel/bindings/webHttpBinding/binding')

            if( $null -eq $bindingNode )
            {
                Write-Verbose "Xml node '/configuration/system.serviceModel/bindings/webHttpBinding/binding' not found in file '$webConfigPath'."  
                return $false
            }

            if( $bindingNode.maxBufferPoolSize -ne $using:bufferSize -or
                $bindingNode.maxReceivedMessageSize -ne $using:bufferSize -or
                $bindingNode.maxBufferSize -ne $using:bufferSize -or
                $bindingNode.transferMode -ne 'Streamed' )
            {
                Write-Verbose "Required attributes on node '/configuration/system.serviceModel/bindings/webHttpBinding/binding' not found or have not the expected values.`n$($bindingNode.Attributes | ForEach-Object { "$($_.Name)='$($_.Value)', " } | Out-String)"  
                return $false
            }
            
            return $true
        }
        SetScript = {
            $webConfigPath = "$using:PhysicalPath\web.config"

            if( -not (Test-Path -Path $webConfigPath) )
            {
                Write-Error "Configuration file '$webConfigPath' not found."  
                return
            }

            Write-Verbose "Reading configuration file '$webConfigPath'."  
            
            [xml]$webConfigXml = Get-Content -Path $webConfigPath

            $serviceModelNode = $webConfigXml.SelectSingleNode( '/configuration/system.serviceModel' ) 
            
            $bindingsNode = $webConfigXml.SelectSingleNode( '/configuration/system.serviceModel/bindings' ) 
            if( $null -eq $bindingsNode )
            {
                $bindingsNode = $webConfigXml.CreateElement( 'bindings' )
                [void]$serviceModelNode.AppendChild( $bindingsNode )
            }
            
            $webHttpBindingNode = $webConfigXml.SelectSingleNode( '/configuration/system.serviceModel/bindings/webHttpBinding' )
            if( $null -eq $webHttpBindingNode )
            {
                $webHttpBindingNode = $webConfigXml.CreateElement( 'webHttpBinding' )
                [void]$bindingsNode.AppendChild( $webHttpBindingNode )
            }
            
            $bindingNode = $webConfigXml.SelectSingleNode( '/configuration/system.serviceModel/bindings/webHttpBinding/binding' )
            if( $null -eq $bindingNode )
            {
                $bindingNode = $webConfigXml.CreateElement( 'binding' )
                [void]$webHttpBindingNode.AppendChild( $bindingNode )
            }
            
            $bindingNode.SetAttribute( 'maxBufferPoolSize', $using:bufferSize )
            $bindingNode.SetAttribute( 'maxReceivedMessageSize', $using:bufferSize )
            $bindingNode.SetAttribute( 'maxBufferSize', $using:bufferSize )
            $bindingNode.SetAttribute( 'transferMode', 'Streamed' )

            Write-Verbose "Set attributes on node '/configuration/system.serviceModel/bindings/webHttpBinding/binding'.`n$($bindingNode.Attributes | ForEach-Object { "$($_.Name)='$($_.Value)', " } | Out-String)"  

            $webConfigXml.Save( $webConfigPath )

            Write-Verbose "Restart IIS..."
            iisreset.exe
        }
        GetScript = { return @{result = 'N/A' } }
        DependsOn = '[xDSCWebService]PSDSCPullServer'
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
