configuration Domain
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
        $SafeModePassword
    )
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.0.1
        
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
        SafemodeAdministratorPassword = $SafeModePassword
        Credential                    = $DomainAdministrator
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
