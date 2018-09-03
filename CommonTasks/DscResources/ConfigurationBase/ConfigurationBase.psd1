@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'ConfigurationBase.schema.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = 'e0d32fb8-6305-4fa3-835e-e89cca22aeba'

    # Author of this module
    Author               = 'NA'

    # Company or vendor of this module
    CompanyName          = 'NA'

    # Copyright statement for this module
    Copyright            = 'NA'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @('xPSDesiredStateConfiguration')

    # DSC resources to export from this module
    DscResourcesToExport = @('ConfigurationBase')
}