@{
    PSDependOptions              = @{
        AddToPath = $True
        Target    = 'BuildOutput\Modules'
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

    #DSC Resources
    xPSDesiredStateConfiguration = '8.4.0.0'
    ComputerManagementDsc        = '5.2.0.0'
    NetworkingDsc                = '6.1.0.0'
}