
Configuration ConfigurationManagerDeployment
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $SiteName,

        [Parameter()]
        [System.String]
        $SiteCode,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $DomainCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SccmInstallAccount,

        [Parameter()]
        [string]
        $SqlServerName,

        [Parameter()]
        [string]
        $DatabaseInstance,

        [Parameter()]
        [System.Nullable[UInt32]]
        $ConfigMgrVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $AdkSetupExePath,

        [Parameter(Mandatory = $true)]
        [string]
        $AdkWinPeSetupPath,

        [Parameter(Mandatory = $true)]
        [string]
        $MdtMsiPath,

        [Parameter(Mandatory = $true)]
        [string]
        $ConfigManagerSetupPath,

        [Parameter()]
        [string]
        $ConfigManagerPath = 'C:\Apps\Microsoft Configuration Manager',

        [Parameter()]
        [string[]]
        $Roles = @('CASorSiteServer', 'ManagementPoint', 'DistributionPoint', 'SoftwareUpdatePoint'),

        [Parameter()]
        [string[]]
        $LocalAdministrators = @('contoso\SCCM-Servers', 'contoso\SCCM-CMInstall', 'contoso\Admin'),

        [Parameter()]
        [string]
        $AdkInstallPath = 'C:\Apps\ADK',

        [Parameter()]
        [string]
        $WsusContentPath = 'C:\Apps\WSUS',

        [Parameter()]
        [string]
        $MdtInstallPath = 'C:\Apps\MDT'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ConfigMgrCBDsc
    Import-DscResource -ModuleName UpdateServicesDsc

    if ($ConfigMgrVersion -lt '1910')
    {
        $adkProductID = 'fb450356-9879-4b2e-8dc9-282709286661'
        $winPeProductID = 'd8369a05-1f4a-4735-9558-6e131201b1a2'
    }
    else
    {
        $adkProductID = '9346016b-6620-4841-8ea4-ad91d3ea02b5'
        $winPeProductID = '353df250-4ecc-4656-a950-4df93078a5fd'
    }

    # SCCM PreReqs
    xSccmPreReqs SCCMPreReqs
    {
        InstallAdk             = $true
        InstallMdt             = $true
        AdkSetupExePath        = $AdkSetupExePath
        AdkWinPeSetupPath      = $AdkWinPeSetupPath
        MdtMsiPath             = $MdtMsiPath
        InstallWindowsFeatures = $true
        WindowsFeatureSource   = 'C:\Windows\WinSxS'
        SccmRole               = $Roles
        LocalAdministrators    = $LocalAdministrators
        DomainCredential       = $DomainCredential
        AdkInstallPath         = $AdkInstallPath
        MdtInstallPath         = $MdtInstallPath
        AdkProductName         = 'Windows Assessment and Deployment Kit - Windows 10'
        AdkProductID           = $adkProductID
        AdkWinPeProductName    = 'Windows Assessment and Deployment Kit Windows Preinstallation Environment Add-ons - Windows 10'
        AdkWinPeProductID      = $winPeProductID
    }

    UpdateServicesServer WSUSConfig
    {
        Ensure            = 'Present'
        SQLServer         = $SqlServerName
        ContentDir        = $WsusContentPath
        Products          = '*'
        Classifications   = '*'
        UpstreamServerSSL = $false
        Synchronize       = $false
        DependsOn         = '[xSccmPreReqs]SCCMPreReqs'
    }

    File CreateIniFolder
    {
        Ensure          = 'Present'
        Type            = 'Directory'
        DestinationPath = 'C:\SetupFiles'
        DependsOn       = '[xSccmPreReqs]SCCMPreReqs'
    }

    CMIniFile CreateSCCMIniFile
    {
        IniFileName               = "Setup_CM_$SiteCode.ini"
        IniFilePath               = 'C:\SetupFiles'
        Action                    = 'InstallPrimarySite'
        CDLatest                  = $false
        ProductID                 = 'eval'
        SiteCode                  = $SiteCode
        SiteName                  = $SiteName
        SMSInstallDir             = $ConfigManagerPath
        SDKServer                 = $($Node.Name)
        RoleCommunicationProtocol = 'HTTPorHTTPS'
        ClientsUsePKICertificate  = $true
        PreRequisiteComp          = $true
        PreRequisitePath          = 'C:\temp\SCCMInstall\Downloads'
        AdminConsole              = $true
        JoinCeip                  = $false
        MobileDeviceLanguage      = $false
        SQLServerName             = $SqlServerName
        DatabaseName              = if ($DatabaseInstance)
        {
            "$DatabaseInstance\CM_$SiteCode"
        }
        else
        {
            "CM_$SiteCode"
        }
        CloudConnector            = $false
        SAActive                  = $true
        CurrentBranch             = $true
        DependsOn                 = '[File]CreateIniFolder'
    }

    xSccmInstall SccmInstall
    {
        SetupExePath       = $ConfigManagerSetupPath
        IniFile            = "C:\SetupFiles\Setup_CM_$SiteCode.ini"
        SccmServerType     = 'Primary'
        SccmInstallAccount = $SccmInstallAccount
        Version            = $ConfigMgrVersion
        DependsOn          = '[CMIniFile]CreateSCCMIniFile'
    }
}
