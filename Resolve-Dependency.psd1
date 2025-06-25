@{
    Gallery                                    = 'PSGallery'
    AllowPrerelease                            = $true
    WithYAML                                   = $true # Will also bootstrap PowerShell-Yaml to read other config files

    UsePSResourceGet                           = $true
    PSResourceGetVersion                       = '1.0.1'

    UsePowerShellGetCompatibilityModule        = $true
    UsePowerShellGetCompatibilityModuleVersion = '3.0.23-beta23'
}
