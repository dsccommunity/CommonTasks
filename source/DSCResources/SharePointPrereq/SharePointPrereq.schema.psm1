configuration SharePointPrereq
{
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $InstallerPath,

        [Parameter(Mandatory = $true)]
        [string]
        $SQLNCli,

        [Parameter(Mandatory = $true)]
        [string]
        $Sync,

        [Parameter(Mandatory = $true)]
        [string]
        $AppFabric,

        [Parameter(Mandatory = $true)]
        [string]
        $IDFX11,

        [Parameter(Mandatory = $true)]
        [string]
        $MSIPCClient,

        [Parameter(Mandatory = $true)]
        [string]
        $WCFDataServices56,

        [Parameter(Mandatory = $true)]
        [string]
        $MSVCRT11,

        [Parameter(Mandatory = $true)]
        [string]
        $MSVCRT141,

        [Parameter(Mandatory = $true)]
        [string]
        $KB3092423,

        [Parameter(Mandatory = $true)]
        [string]
        $DotNet472,

        [Parameter(Mandatory = $true)]
        [string]
        $IsoFilePath,

        [Parameter(Mandatory = $true)]
        [string]
        $IsoDriveLetter,

        [Parameter(Mandatory = $true)]
        [string]
        $ProductKey
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC
    Import-DscResource -ModuleName storageDsc

    MountImage SharePointServerIso
    {
        ImagePath   = $IsoFilePath
        DriveLetter = $IsoDriveLetter
        StorageType = 'ISO'
        Ensure      = 'Present'
    }

    SPInstallPrereqs SharePointInstallationPrerequisite
    {
        IsSingleInstance  = 'Yes'
        InstallerPath     = $InstallerPath
        OnlineMode        = $false
        SQLNCli           = $SQLNCli
        Sync              = $Sync
        DotNet472         = $DotNet472
        AppFabric         = $AppFabric
        IDFX11            = $IDFX11
        MSIPCClient       = $MSIPCClient
        WCFDataServices56 = $WCFDataServices56
        MSVCRT141         = $MSVCRT141
        MSVCRT11          = $MSVCRT11
        KB3092423         = $KB3092423
    }

    SPInstall SharePointInstallation
    {
        IsSingleInstance = 'Yes'
        Ensure           = 'Present'
        BinaryDir        = $IsoDriveLetter
        ProductKey       = $ProductKey
        #PsDscRunAsCredential = $SetupAccount
        DependsOn        = '[SPInstallPrereqs]SharePointInstallationPrerequisite'
    }
}
