configuration AddsDomain
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DomainFQDN,

        [Parameter(Mandatory)]
        [string]
        $DomainName,

        [Parameter()]
        [hashtable[]]
        $DomainTrust,

        [Parameter()]
        [string]
        $DomainDn,

        [Parameter()]
        [pscredential]
        $DomainJoinAccount, # Placeholder to be able to store domain join account in the yaml files

        [Parameter()]
        [pscredential]
        $DomainAdministrator,

        [Parameter()]
        [pscredential]
        $SafeModeAdministratorPassword,

        [Parameter()]
        [string]
        $DatabasePath = 'C:\Windows\NTDS',

        [Parameter()]
        [string]        
        $LogPath = 'C:\Windows\Logs',

        [Parameter()]
        [string]
        $SysvolPath = 'C:\Windows\SYSVOL',

        [Parameter()]
        [string]
        $ForestMode = 'WinThreshold'
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc
        
    WindowsFeature ADDS
    {
        Name   = 'AD-Domain-Services'
        Ensure = 'Present'        
    }

    WindowsFeature RSAT
    {
        Name   = 'RSAT-AD-PowerShell'
        Ensure = 'Present'
    }

    ADDomain $DomainName
    {
        DomainName                    = $DomainFQDN
        DomainNetbiosName             = $DomainName
        SafemodeAdministratorPassword = $SafeModeAdministratorPassword
        Credential                    = $DomainAdministrator
        DatabasePath                  = $DatabasePath
        LogPath                       = $LogPath
        SysvolPath                    = $SysvolPath
        ForestMode = $ForestMode
    }
    
    ADOptionalFeature RecycleBin 
    {
        DependsOn                         = "[ADDomain]$DomainName"
        ForestFQDN                        = $DomainFQDN
        EnterpriseAdministratorCredential = $DomainAdministrator
        FeatureName                       = 'Recycle Bin Feature'
    }

    foreach ($trust in $DomainTrust)
    {
        WaitForAdDomain $trust.Name
        {
            DomainName = $trust.Fqdn
            Credential = $trust.Credential
        }

        ADDomainTrust $trust.Name
        {
            SourceDomainName = $DomainName
            TargetCredential = $trust.Credential
            TargetDomainName = $trust.Fqdn
            TrustDirection   = 'Bidirectional'
            TrustType        = 'Forest'
            DependsOn        = "[WaitForAdDomain]$($trust.Name)"
        }
    }
}
