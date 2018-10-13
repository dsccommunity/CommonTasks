@{
    RootModule           = 'Network.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = '197e8e36-8686-4135-9d16-72d0dbfafee9'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'NetworkingDsc'; ModuleVersion = '6.1.0.0' }
    #)

    DscResourcesToExport = @('Network')
}