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
    ProtectedData                = 'latest'
    PowershellGet                = 'latest'
    DscBuildHelpers              = 'latest'

    #DSC Resources
    xPSDesiredStateConfiguration = '8.4.0.0'
    ComputerManagementDsc        = '6.1.0.0'
    NetworkingDsc                = '6.3.0.0'
    JeaDsc                       = '0.5.0'
    XmlContentDsc                = '0.0.1'
}