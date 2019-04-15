@{
    RootModule           = 'DscLcmMaintenanceWindows.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = 'f89ef950-808a-4698-ad82-649352863022'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #)

    DscResourcesToExport = @('DscLcmMaintenanceWindows')
}