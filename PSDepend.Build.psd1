@{
    PSDependOptions   = @{
        AddToPath = $True
        Target    = 'BuildOutput\Modules'
    }

    BuildHelpers      = 'latest'
    InvokeBuild       = 'latest'
    Pester            = 'latest'
    PSScriptAnalyzer  = 'latest'
    PSDeploy          = 'latest'
    Datum             = 'latest'
    ProtectedData     = 'latest'
    'powershell-yaml' = 'latest'
}