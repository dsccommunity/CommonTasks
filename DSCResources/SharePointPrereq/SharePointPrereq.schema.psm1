configuration SharePointPrereq
{
    param(
        [Parameter(Mandatory)]
        [string]$InstallerPath,
        
        [Parameter(Mandatory)]
        [string]$SQLNCli,
        
        [Parameter(Mandatory)]
        [string]$Sync,

        [Parameter(Mandatory)]
        [string]$AppFabric,
        
        [Parameter(Mandatory)]
        [string]$IDFX11,

        [Parameter(Mandatory)]
        [string]$MSIPCClient,
        
        [Parameter(Mandatory)]
        [string]$WCFDataServices56,

        [Parameter(Mandatory)]
        [string]$MSVCRT11,
        
        [Parameter(Mandatory)]
        [string]$MSVCRT141,
        
        [Parameter(Mandatory)]
        [string]$KB3092423,

        [Parameter(Mandatory)]
        [string]$DotNet472,

        [Parameter(Mandatory)]
        [string]$IsoFilePath,

        [Parameter(Mandatory)]
        [string]$IsoDriveLetter,

        [Parameter(Mandatory)]
        [string]$ProductKey
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC
    Import-DscResource -ModuleName storageDsc

    MountImage SharePointServerIso {
        ImagePath = $IsoFilePath
        DriveLetter = $IsoDriveLetter
        StorageType = 'ISO'
        Ensure = 'Present'
    }

    SPInstallPrereqs SharePointInstallationPrerequisite
    {
        IsSingleInstance     = 'Yes'
        InstallerPath        = $InstallerPath
        OnlineMode           = $false
        SQLNCli              = $SQLNCli
        Sync                 = $Sync
        DotNet472            = $DotNet472
        AppFabric            = $AppFabric
        IDFX11               = $IDFX11
        MSIPCClient          = $MSIPCClient
        WCFDataServices56    = $WCFDataServices56
        MSVCRT141            = $MSVCRT141
        MSVCRT11             = $MSVCRT11
        KB3092423            = $KB3092423
    }

    SPInstall SharePointInstallation
    {   
        IsSingleInstance     = 'Yes'
        Ensure               = 'Present'
        BinaryDir            = $IsoDriveLetter
        ProductKey           = $ProductKey
        #PsDscRunAsCredential = $SetupAccount
        DependsOn            = '[SPInstallPrereqs]SharePointInstallationPrerequisite'
    }
}
