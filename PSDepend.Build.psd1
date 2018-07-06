@{
    PSDependOptions  = @{
        AddToPath  = $True
        Target     = 'BuildOutput\Modules'
    }

    InvokeBuild      = 'latest'
    Pester           = 'latest'
    PSScriptAnalyzer = 'latest'
    PSDeploy         = 'latest'
}