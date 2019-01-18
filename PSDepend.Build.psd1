@{
    PSDependOptions              = @{
        AddToPath      = $true
        Target         = 'BuildOutput\Modules'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository = 'PSGallery'
        }
    }

    #Modules
    BuildHelpers                 = 'latest'
    InvokeBuild                  = 'latest'
    Pester                       = 'latest'
    PSScriptAnalyzer             = 'latest'
    PSDeploy                     = 'latest'
    Datum                        = 'latest'
    ProtectedData                = 'latest'
    'powershell-yaml'            = 'latest'
    PowershellGet                = 'latest' 

    #DSC Resources
    xPSDesiredStateConfiguration = '8.4.0.0'
    ComputerManagementDsc        = '6.1.0.0'
    NetworkingDsc                = '6.3.0.0'
}