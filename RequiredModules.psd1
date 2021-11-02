@{
    PSDependOptions              = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    'powershell-yaml'            = 'latest'
    InvokeBuild                  = 'latest'
    PSScriptAnalyzer             = 'latest'
    Pester                       = '4.10.1'
    Plaster                      = 'latest'
    ModuleBuilder                = 'latest'
    ChangelogManagement          = 'latest'
    Sampler                      = 'latest'
    Datum                        = '0.39.0'
    'Datum.ProtectedData'        = '0.0.1'
    DscBuildHelpers              = '0.0.42'

    # DSC Resources
    xPSDesiredStateConfiguration = '9.1.0'
    ComputerManagementDsc        = '8.5.0'
    ActiveDirectoryDsc           = '6.0.1'
}
