@{
    RootModule           = 'SoftwarePackage.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = '0245e22a-4b66-44e6-ba2b-1aa8df37ef67'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #)

    DscResourcesToExport = @('SoftwarePackage')
}