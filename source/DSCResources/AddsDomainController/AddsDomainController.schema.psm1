configuration AddsDomainController
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
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
        [bool]
        $IsReadOnlyReplica = $false,

        [Parameter()]
        [string[]]
        $AllowPWReplication,

        [Parameter()]
        [string[]]
        $DenyPWReplication,

        [Parameter()]
        [bool]
        $UnprotectFromAccidentalDeletion = $false,

        [Parameter()]
        [string]
        $InstallationMediaPath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    WindowsFeature ADDS
    {
        Name   = 'AD-Domain-Services'
        Ensure = 'Present'
    }

    WindowsFeature RSATADPowerShell
    {
        Name      = 'RSAT-AD-PowerShell'
        Ensure    = 'Present'
        DependsOn = '[WindowsFeature]ADDS'
    }

    WaitForADDomain 'WaitForestAvailability' {
        DomainName = $DomainName
        Credential = $Credential
        DependsOn  = '[WindowsFeature]RSATADPowerShell'
    }

    $depOn = '[WaitForADDomain]WaitForestAvailability'

    if ( $UnprotectFromAccidentalDeletion )
    {
        Script RemoveProtectFromAccidentalDeletionBeforeDcPromo
        {
            TestScript = {
                try
                {
                    Get-ADDomainController -Identity $env:ComputerName
                    Write-Verbose "Computer '$env:ComputerName' is a domain controller. Nothing to do"
                    return $true
                }
                catch
                {
                    Write-Verbose "Computer '$env:ComputerName' is not a domain controller. Reset of 'Protect from Accidental Deletion' before DC promote is necessary"
                    return $false
                }
            }
            SetScript  = {
                Write-Verbose "Reset flag 'Protect from Accidental Deletion' from computer account '$env:ComputerName'."
                Get-ADComputer $env:ComputerName | Set-ADObject -ProtectedFromAccidentalDeletion $false
            }
            GetScript  = { return `
                @{
                    result = 'N/A'
                }
            }
            DependsOn  = $depOn
        }

        $depOn = '[Script]RemoveProtectFromAccidentalDeletionBeforeDcPromo'
    }

    if ($IsReadOnlyReplica -eq $false)
    {
        ADDomainController 'DomainControllerAllProperties'
        {
            DomainName                    = $DomainName
            Credential                    = $Credential
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword
            DatabasePath                  = $DatabasePath
            LogPath                       = $LogPath
            SysvolPath                    = $SysvolPath
            SiteName                      = $SiteName
            ReadOnlyReplica               = $IsReadOnlyReplica
            IsGlobalCatalog               = $IsGlobalCatalog
            DependsOn                     = $depOn
        }
    }
    elseif ($IsReadOnlyReplica -eq $true)
    {
        ADDomainController 'DomainControllerAllProperties'
        {
            DomainName                          = $DomainName
            Credential                          = $Credential
            SafeModeAdministratorPassword       = $SafeModeAdministratorPassword
            DatabasePath                        = $DatabasePath
            LogPath                             = $LogPath
            SysvolPath                          = $SysvolPath
            SiteName                            = $SiteName
            ReadOnlyReplica                     = $IsReadOnlyReplica
            IsGlobalCatalog                     = $IsGlobalCatalog
            AllowPasswordReplicationAccountName = $AllowPWReplication
            DenyPasswordReplicationAccountName  = $DenyPWReplication
            DependsOn                           = $depOn
        }
    }
}
