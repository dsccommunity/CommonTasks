@{
    RootModule           = 'NetworkIpConfiguration.schema.psm1'

    ModuleVersion        = '0.0.1'

    GUID                 = 'a17a202a-e7f1-4279-aa73-3e3aadbc461c'

    Author               = 'NA'

    CompanyName          = 'NA'

    Copyright            = 'NA'

    #RequiredModules      = @(
    #    @{ ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '8.4.0.0' }
    #    @{ ModuleName = 'NetworkingDsc'; ModuleVersion = '6.1.0.0' }
    #)

    DscResourcesToExport = @('NetworkIpConfiguration')
}