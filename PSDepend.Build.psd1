@{

    PSDependOptions              = @{
        AddToPath      = $true
        Target         = 'BuildOutput\Modules'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository      = 'PSGallery'
            AllowPreRelease = $true
        }
    }

    #Modules
    BuildHelpers                 = '2.0.16'
    InvokeBuild                  = '5.8.4'
    Pester                       = '4.10.1'
    PSScriptAnalyzer             = '1.20.0'
    PSDeploy                     = '1.0.5'
    ProtectedData                = '4.1.3'
    DscBuildHelpers              = '0.0.42'
    Datum                        = '0.39.0'
    'powershell-yaml'            = '0.4.2'
    'Datum.ProtectedData'        = '0.0.1'

    #DSC Resources
    xPSDesiredStateConfiguration = '9.1.0'
    ComputerManagementDsc        = '8.5.0'
    NetworkingDsc                = '8.2.0'
    JeaDsc                       = '0.7.2'
    XmlContentDsc                = '0.0.1'
    xWebAdministration           = '3.2.0'
    SecurityPolicyDsc            = '2.10.0.0'
    StorageDsc                   = '5.0.1'
    Chocolatey                   = '0.0.79'
    ActiveDirectoryDsc           = '6.0.1'
    DfsDsc                       = '4.4.0.0'
    WdsDsc                       = '0.11.0'
    xDhcpServer                  = '3.0.0'
    xDscDiagnostics              = '2.8.0'
    DnsServerDsc                 = '3.0.0'
    xFailoverCluster             = '1.16.0'
    GPRegistryPolicyDsc          = '1.2.0'
    AuditPolicyDsc               = '1.4.0.0'
    SharePointDSC                = '4.8.0'
    xExchange                    = '1.32.0'
    SqlServerDsc                 = '15.2.0'
    UpdateServicesDsc            = '1.2.1'
    xWindowsEventForwarding      = '1.0.0.0'
    OfficeOnlineServerDsc        = '1.5.0'
    xBitlocker                   = '1.4.0.0'
    ActiveDirectoryCSDsc         = '5.0.0'
    'xHyper-V'                   = '3.17.0.0'
    DSCR_PowerPlan               = '1.3.0'
    FileSystemDsc                = '1.1.1'
    PackageManagement            = '1.4.7'
    PowerShellGet                = '2.2.5'
    ConfigMgrCBDsc               = '2.1.0-preview0006' # Gallery version has extremely old SQL dependencies
}
