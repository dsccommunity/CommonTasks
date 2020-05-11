@{
    RootModule           = 'DscDiagnostic.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = '20392fe9-270d-4295-af2c-0749dd015596'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #)

    DscResourcesToExport = @('DscDiagnostic')
}