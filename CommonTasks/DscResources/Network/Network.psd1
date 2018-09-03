@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'Network.schema.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.1'

    # ID used to uniquely identify this module
    GUID                 = '197e8e36-8686-4135-9d16-72d0dbfafee9'

    # Author of this module
    Author               = 'NA'

    # Company or vendor of this module
    CompanyName          = 'NA'

    # Copyright statement for this module
    Copyright            = 'NA'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @('xPSDesiredStateConfiguration')

    # DSC resources to export from this module
    DscResourcesToExport = @('Network')
}