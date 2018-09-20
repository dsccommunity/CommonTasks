@{
    RootModule           = 'SecurityBase.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = '6b2f1809-107e-474b-84fa-d0a658ef4285'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'ComputerManagementDsc'; ModuleVersion = '5.2.0.0' }
    #)

    DscResourcesToExport = @('SecurityBase')
}