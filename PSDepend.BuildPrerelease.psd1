@{

    PSDependOptions = @{
        AddToPath      = $true
        Target         = 'BuildOutput\Modules'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository      = 'PSGallery'
            AllowPreRelease = $true
        }
    }

    ConfigMgrCBDsc  = '2.1.0-preview0006' # Gallery version has extremely old SQL dependencies
}
