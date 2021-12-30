configuration ExchangeProvisioning {
    param (
        [Parameter()]
        [ValidateSet('Mailbox', 'EdgeTransport', 'ManagementTools')]
        [string]$Role = 'Mailbox',

        [Parameter()]
        [ValidateSet('Install', 'Uninstall', 'Upgrade')]
        [string]$Mode = 'Install',

        [Parameter()]
        [string]$TargetDir,

        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [PSCredential]$InstallCreds,

        [Parameter()]
        [string]$DomainController,

        [Parameter()]
        [string]$ProductKey,

        [Parameter(Mandatory = $true)]
        [string]$IsoFilePath,

        [Parameter(Mandatory = $true)]
        [string]$IsoDriveLetter
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xExchange
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName StorageDsc

    #Check if a reboot is needed before installing Exchange
    PendingReboot BeforeExchangeInstall
    {
        Name = 'BeforeExchangeInstall'
    }

    MountImage ExchangeServerIso
    {
        ImagePath   = $IsoFilePath
        DriveLetter = $IsoDriveLetter
        StorageType = 'ISO'
        Ensure      = 'Present'
    }

    #Do the Exchange install
    $installationArguments = "/Mode:$Mode /Role:$Role /IAcceptExchangeServerLicenseTerms /OrganizationName:$OrganizationName"
    if ($DomainController)
    {
        $installationArguments += " /DomainController:$DomainController"
    }
    if ($TargetDir)
    {
        $installationArguments += " /TargetDir:$TargetDir"
    }

    xExchInstall InstallExchange
    {
        Path       = "$($IsoDriveLetter)\Setup.exe"
        Arguments  = $installationArguments
        Credential = $InstallCreds
        DependsOn  = '[PendingReboot]BeforeExchangeInstall'
    }

    #This section licenses the server
    xExchExchangeServer EXServer
    {
        Identity            = $Node.NodeName
        Credential          = $InstallCreds
        ProductKey          = $ProductKey
        AllowServiceRestart = $true
        DependsOn           = '[xExchInstall]InstallExchange'
    }

    #See if a reboot is required after installing Exchange
    PendingReboot AfterExchangeInstall
    {
        Name      = 'AfterExchangeInstall'
        DependsOn = '[xExchInstall]InstallExchange'
    }
}
