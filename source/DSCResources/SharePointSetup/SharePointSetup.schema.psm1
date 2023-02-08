<# SharePointDSC minimum version 5.0.0
    Resource to install the SharePoint Server Prerequisits, the SharePoint Server and optionally Language Packs.
    Uses the DSC Ressources:
    - SPInstallPrereqs
    - SPInstall
    - SPInstallLanguagePack

    Example for SharePoint Server 2019:
    SharePointSetup:
      InstallerPath: 'C:\SharePoint Server 2019\Setup\PrerequisiteInstaller.exe'
      OnlineMode: false
      KB3092423: 'C:\SharePoint Server 2019\Prerequisite Installer Files\AppFabric-KB3092423-x64-ENU.exe'
      DotNet472: 'C:\SharePoint Server 2019\Prerequisite Installer Files\NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
      IDFX11: 'C:\\SharePoint Server 2019\Prerequisite Installer Files\MicrosoftIdentityExtensions-64.msi'
      MSIPCClient: 'C:\SharePoint Server 2019\Prerequisite Installer Files\setup_msipc_x64.exe'
      SQLNCli: 'C:\SharePoint Server 2019\Prerequisite Installer Files\sqlncli.msi'
      Sync: 'C:\SharePoint Server 2019\Prerequisite Installer Files\Synchronization.msi'
      WCFDataServices56: 'C:\SharePoint Server 2019\Prerequisite Installer Files\WcfDataServices.exe'
      MSVCRT11: 'C:\SharePoint Server 2019\Prerequisite Installer Files\vc11redist_x64.exe'
      MSVCRT141: 'C:\SharePoint Server 2019\Prerequisite Installer Files\vc_redist.x64.exe'
      AppFabric: 'C:\SharePoint Server 2019\Prerequisite Installer Files\WindowsServerAppFabricSetup_x64.exe'
      BinaryDir: 'C:\SharePoint Server 2019\Setup\'
      ProductKey: key-key-key-key-key
      InstallPath: 'C:\Program Files\Microsoft Office Servers'
      DataPath: 'C:\Program Files\Microsoft Office Servers'
      LanguagePacks:
        - BinaryDir: 'C:\SharePoint Server 2019\Language Pack DE'
#>
configuration SharePointSetup
{
    param (
        # SharePoint prerequisites
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstallerPath,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $OnlineMode,

        [Parameter()]
        [System.String]
        $SXSpath,

        [Parameter()]
        [System.String]
        $SQLNCli,

        [Parameter()]
        [System.String]
        $PowerShell,

        [Parameter()]
        [System.String]
        $NETFX,

        [Parameter()]
        [System.String]
        $IDFX,

        [Parameter()]
        [System.String]
        $Sync,

        [Parameter()]
        [System.String]
        $AppFabric,

        [Parameter()]
        [System.String]
        $IDFX11,

        [Parameter()]
        [System.String]
        $MSIPCClient,

        [Parameter()]
        [System.String]
        $WCFDataServices,

        [Parameter()]
        [System.String]
        $KB2671763,

        [Parameter()]
        [System.String]
        $WCFDataServices56,

        [Parameter()]
        [System.String]
        $MSVCRT11,

        [Parameter()]
        [System.String]
        $MSVCRT14,

        [Parameter()]
        [System.String]
        $MSVCRT141,

        [Parameter()]
        [System.String]
        $MSVCRT142,

        [Parameter()]
        [System.String]
        $KB3092423,

        [Parameter()]
        [System.String]
        $ODBC,

        [Parameter()]
        [System.String]
        $DotNetFx,

        [Parameter()]
        [System.String]
        $DotNet472,

        [Parameter()]
        [System.String]
        $DotNet48,

        # SharePoint Server Setup

        [Parameter(Mandatory = $true)]
        [string]
        $BinaryDir,

        [Parameter(Mandatory = $true)]
        [string]
        $ProductKey,

        [Parameter()]
        [System.String]
        $InstallPath,

        [Parameter()]
        [System.String]
        $DataPath,

        # SharePoint LanguagePacks
        [Parameter()]
        [hashtable[]]
        $LanguagePacks
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SharePointDSC

    # SharePoint Prerequisits Installer
    $spInstallPrereqs = @{
        IsSingleInstance = 'Yes'
        InstallerPath    = $InstallerPath
        OnlineMode       = $OnlineMode
    }
    # Add optional spInstallPrereqs Parameter
    $spInstallPrereqsOptional = @(
        'SXSpath', 'SQLNCli', 'PowerShell', 'NETFX', 'IDFX', 'Sync', 'AppFabric', 'IDFX11', 'MSIPCClient', 'WCFDataServices', 'KB2671763', 'WCFDataServices56', 'MSVCRT11', 'MSVCRT14', 'MSVCRT141', 'MSVCRT142', 'KB3092423', 'ODBC', 'DotNetFx', 'DotNet472', 'DotNet48'
    )
    foreach ($parameter in $spInstallPrereqsOptional)
    {
        if ($PSBoundParameters.ContainsKey($parameter))
        {
            $spInstallPrereqs.Add($parameter, $PSBoundParameters.Item($parameter))
        }
    }
    (Get-DscSplattedResource -ResourceName SPInstallPrereqs -ExecutionName 'InstallPrerequisites' -Properties $spInstallPrereqs -NoInvoke).Invoke($spInstallPrereqs)

    # SharePoint Setup
    $spInstall = @{
        IsSingleInstance = 'Yes'
        BinaryDir = $BinaryDir
        ProductKey = $ProductKey
        DependsOn = '[SPInstallPrereqs]InstallPrerequisites'
    }
    $spInstallOptional = @(
        'InstallPath', 'DataPath'
    )
    foreach ($parameter in $spInstallOptional)
    {
        if ($PSBoundParameters.ContainsKey($parameter))
        {
            $spInstall.Add($parameter, $PSBoundParameters.Item($parameter))
        }
    }
    (Get-DscSplattedResource -ResourceName SPInstall -ExecutionName 'InstallBinaries' -Properties $spInstall -NoInvoke).Invoke($spInstall)

    # Language Packs
    $i = 0
    foreach ($languagePack in $LanguagePacks)
    {
        $languagePack.Add('DependsOn', '[SPInstall]InstallBinaries')
        $executionName = "InstallLPBinaries-Language$i"
        $i++
        (Get-DscSplattedResource -ResourceName SPInstallLanguagePack -ExecutionName $executionName -Properties $languagePack -NoInvoke).Invoke($languagePack)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
