configuration AzureConnectedMachine
{
    param
    (
        [Parameter()]
        [string]
        $DownloadProxy,

        [Parameter()]
        [string]
        $DownloadPath = 'C:\DSCData\ACMA',

        [Parameter()]
        [string]
        $DownloadURL = 'https://aka.ms/AzureConnectedMachineAgent',

        [Parameter(Mandatory = $true)]
        [string]
        $TenantId,

        [Parameter(Mandatory = $true)]
        [string]
        $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string]
        $Location,

        [Parameter()]
        $Tags,

        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential,

        [Parameter()]
        [string]
        $IsSingleInstance = "Yes",

        [Parameter()]
        [string[]]
        $incomingconnections_ports,

        [Parameter()]
        [string]
        $proxy_url,

        [Parameter()]
        [string[]]
        $extensions_allowlist,

        [Parameter()]
        [string[]]
        $extensions_blocklist,

        [Parameter()]
        [string[]]
        $proxy_bypass,

        [Parameter()]
        [boolean]
        $guestconfiguration_enabled
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName AzureConnectedMachineDsc

    xRemoteFile DownloadHIMDS
    {
        DestinationPath = "$DownloadPath\AzureConnectedMachineAgent.msi"
        Uri             = $DownloadURL
        Proxy           = $DownloadProxy
    }

    xPackage InstallHIMDS
    {
        Name            = 'Azure Connected Machine Agent'
        Ensure          = 'Present'
        ProductId       = ''
        Path            = "$DownloadPath\AzureConnectedMachineAgent.msi"
        DependsOn       = '[xRemoteFile]DownloadHIMDS'
    }

    xService HIMDS{
        Ensure          = 'Present'
        Name            = 'HIMDS'
        State           = 'Running'
        DependsOn       = '[xPackage]InstallHIMDS'
    }

    AzureConnectedMachineAgentDsc Connect{
        TenantId        = $TenantId
        SubscriptionId  = $SubscriptionId
        ResourceGroup   = $ResourceGroup
        Location        = $Location
        Tags            = $Tags
        Credential      = $Credential
        DependsOn       = '[xService]HIMDS'
    }

    AzcmagentConfig Ports{
        IsSingleInstance            = $IsSingleInstance
        incomingconnections_ports   = $incomingconnections_ports
        proxy_url                   = $proxy_url
        extensions_allowlist        = $extensions_allowlist
        extensions_blocklist        = $extensions_blocklist
        proxy_bypass                = $proxy_bypass
        guestconfiguration_enabled  = $guestconfiguration_enabled
        DependsOn                   = '[AzureConnectedMachineAgentDsc]Connect'
    }
}
