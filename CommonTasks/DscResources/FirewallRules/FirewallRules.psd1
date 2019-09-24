@{
    RootModule           = 'FirewallRules.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = '1c7193c4-430d-491f-a20f-30f7159560b0'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'NetworkingDsc'; ModuleVersion = '6.1.0.0' }
    #)

    DscResourcesToExport = @('FirewallRules')
}