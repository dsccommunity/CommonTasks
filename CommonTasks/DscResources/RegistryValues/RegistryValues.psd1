@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'RegistryValues.schema.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '2aab897b-85c4-4643-8928-67892348dd1a'

    # Author of this module
    Author               = 'NA'

    # Company or vendor of this module
    CompanyName          = 'NA'

    # Copyright statement for this module
    Copyright            = 'NA'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @('PSDesiredStateConfiguration')

    # DSC resources to export from this module
    DscResourcesToExport = @('RegistryValues')
}