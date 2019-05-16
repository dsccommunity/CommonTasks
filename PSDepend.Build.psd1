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
    DscBuildHelpers              = 'latest'

    #DSC Resources
    xPSDesiredStateConfiguration = '8.6.0.0'
    ComputerManagementDsc        = '6.4.0.0'
    NetworkingDsc                = '7.1.0.0'
    JeaDsc                       = '0.6.2'
    XmlContentDsc                = '0.0.1'
    xWebAdministration           = '2.5.0.0'
}