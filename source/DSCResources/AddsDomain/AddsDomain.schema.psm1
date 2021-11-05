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
        $ForestMode = 'WinThreshold',

        [Parameter()]
        [boolean]
        $ForceRebootBefore,

        [Parameter()]
        [hashtable[]]
        $DomainTrusts,

        [Parameter()]
        [boolean]
        $EnablePrivilegedAccessManagement = $false
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
        
    WindowsFeature ADDS
    {
        Name   = 'AD-Domain-Services'
        Ensure = 'Present'
    }

    WindowsFeature RSAT
    {
        Name      = 'RSAT-AD-PowerShell'
        Ensure    = 'Present'
        DependsOn = '[WindowsFeature]ADDS'
    }
    
   [string]$nextDependsOn = '[WindowsFeature]RSAT'

    if ($ForceRebootBefore -eq $true)
    {
        $rebootKeyName = 'HKLM:\SOFTWARE\DSC Community\CommonTasks\RebootRequests'
        $rebootVarName = 'RebootBefore_ADDomain'

        Script $rebootVarName
        {
            TestScript = {
                $val = Get-ItemProperty -Path $using:rebootKeyName -Name $using:rebootVarName -ErrorAction SilentlyContinue

                if ($val -ne $null -and $val.$rebootVarName -gt 0) { 
                    return $true
                }   
                return $false
            }
            SetScript = {
                if( -not (Test-Path -Path $using:rebootKeyName) ) {
                    New-Item -Path $using:rebootKeyName -Force
                }
                Set-ItemProperty -Path $rebootKeyName -Name $using:rebootVarName -value 1
                $global:DSCMachineStatus = 1             
            }
            GetScript = { return @{result = 'result'}}
            DependsOn = $nextDependsOn
        }        

        $nextDependsOn = "[Script]$rebootVarName"
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
        ForestMode                    = $ForestMode
        DependsOn                     = $nextDependsOn
    }

    # assign DomainAdministrator to group 'Enterprise Admins' - otherwise ADOptionalFeature will fail with insufficient rights
    ADGroup "EnterpriseAdmins_$DomainName"
    {
        GroupName        = 'Enterprise Admins'
        MembersToInclude = $(Split-Path -Path $DomainAdministrator.UserName -Leaf)
        DependsOn        = "[ADDomain]$DomainName"
    }
    
    ADOptionalFeature RecycleBinFeature 
    {
        DependsOn                         = "[ADGroup]EnterpriseAdmins_$DomainName"
        ForestFQDN                        = $DomainFQDN
        EnterpriseAdministratorCredential = $DomainAdministrator
        FeatureName                       = 'Recycle Bin Feature'
    }

    if( $EnablePrivilegedAccessManagement -eq $true )
    {
        ADOptionalFeature PrivilegedAccessManagementFeature 
        {
            DependsOn                         = "[ADGroup]EnterpriseAdmins_$DomainName"
            ForestFQDN                        = $DomainFQDN
            EnterpriseAdministratorCredential = $DomainAdministrator
            FeatureName                       = 'Privileged Access Management Feature'
        }  
    }

    foreach ($trust in $DomainTrusts)
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
