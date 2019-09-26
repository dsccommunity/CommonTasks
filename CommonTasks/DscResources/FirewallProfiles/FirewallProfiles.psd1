@{
    RootModule           = 'FirewallProfiles.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = 'e9517597-219b-433c-82a5-3ccfbfa14a3b'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'NetworkingDsc'; ModuleVersion = '6.1.0.0' }
    #)

    DscResourcesToExport = @('FirewallProfiles')
}