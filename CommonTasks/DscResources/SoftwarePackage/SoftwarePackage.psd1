@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'SoftwarePackage.schema.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '0245e22a-4b66-44e6-ba2b-1aa8df37ef67'

    # Author of this module
    Author               = 'NA'

    # Company or vendor of this module
    CompanyName          = 'NA'

    # Copyright statement for this module
    Copyright            = 'NA'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @('xPSDesiredStateConfiguration')

    # DSC resources to export from this module
    DscResourcesToExport = @('SoftwarePackage')
}