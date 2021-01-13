configuration AddsDomainController
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $DomainName,

        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory)]
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
        $SiteName,

        [Parameter()]
        [bool]        
        $IsGlobalCatalog = $true,

        [Parameter()]
        [string]
        $InstallationMediaPath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
        
    WindowsFeature ADDS {
        Name   = 'AD-Domain-Services'
        Ensure = 'Present'
    }

    WindowsFeature RSATADPowerShell {
        Name      = 'RSAT-AD-PowerShell'
        Ensure    = 'Present'
        DependsOn = '[WindowsFeature]ADDS'
    }

    WaitForADDomain 'WaitForestAvailability' {
        DomainName = $DomainName
        Credential = $Credential
        DependsOn  = '[WindowsFeature]RSATADPowerShell'
    }

    ADDomainController 'DomainControllerAllProperties' {
        DomainName                    = $DomainName
        Credential                    = $Credential
        SafeModeAdministratorPassword = $SafeModeAdministratorPassword
        DatabasePath                  = $DatabasePath
        LogPath                       = $LogPath
        SysvolPath                    = $SysvolPath
        SiteName                      = $SiteName
        IsGlobalCatalog               = $IsGlobalCatalog
        DependsOn                     = '[WaitForADDomain]WaitForestAvailability'
    }
}
