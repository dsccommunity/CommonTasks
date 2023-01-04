@{
    PSDependOptions              = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository      = 'PSGallery'
            AllowPreRelease = $true
        }
    }

    InvokeBuild                  = 'latest'
    PSScriptAnalyzer             = 'latest'
    Pester                       = 'latest'
    Plaster                      = 'latest'
    ModuleBuilder                = 'latest'
    ChangelogManagement          = 'latest'
    Sampler                      = 'latest'
    'Sampler.GitHubTasks'        = 'latest'
    Datum                        = 'latest'
    'Datum.ProtectedData'        = 'latest'
    DscBuildHelpers              = 'latest'
    'DscResource.Test'           = 'latest'
    MarkdownLinkCheck            = 'latest'
    'DscResource.AnalyzerRules'  = 'latest'
    'DscResource.DocGenerator'   = 'latest'

    #DSC Resources
    xPSDesiredStateConfiguration = '9.1.0'
    ComputerManagementDsc        = '8.5.0'
    NetworkingDsc                = '9.0.0'
    JeaDsc                       = '0.7.2'
    XmlContentDsc                = '0.0.1'
    xWebAdministration           = '3.3.0'
    SecurityPolicyDsc            = '2.10.0.0'
    StorageDsc                   = '5.0.1'
    Chocolatey                   = '0.0.79'
    ActiveDirectoryDsc           = '6.2.0'
    DfsDsc                       = '4.4.0.0'
    WdsDsc                       = '0.11.0'
    xDhcpServer                  = '3.1.0'
    xDscDiagnostics              = '2.8.0'
    DnsServerDsc                 = '3.0.0'
    xFailoverCluster             = '1.16.1'
    GPRegistryPolicyDsc          = '1.2.0'
    AuditPolicyDsc               = '1.4.0.0'
    SharePointDSC                = '4.8.0'
    xExchange                    = '1.33.0'
    SqlServerDsc                 = '16.1.0-preview0009'
    UpdateServicesDsc            = '1.2.1'
    xWindowsEventForwarding      = '1.0.0.0'
    OfficeOnlineServerDsc        = '1.5.0'
    xBitlocker                   = '1.4.0.0'
    ActiveDirectoryCSDsc         = '5.0.0'
    'xHyper-V'                   = '3.18.0'
    DSCR_PowerPlan               = '1.3.0'
    FileSystemDsc                = '1.1.1'
    PackageManagement            = '1.4.8.1'
    PowerShellGet                = '2.2.5'
    ConfigMgrCBDsc               = '3.0.0'
    MmaDsc                       = '1.3.0'
    CertificateDsc               = '5.1.0'
    xRobocopy                    = '2.0.0.0'
    VSTSAgent                    = '2.0.14'
    FileContentDsc               = '1.3.0.151'
    xRemoteDesktopSessionHost    = '2.1.1-preview0001'
    cScom                        = '1.0.4'
}
