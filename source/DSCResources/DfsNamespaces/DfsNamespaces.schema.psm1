configuration DfsNamespaces
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $DomainFqdn,
        
        [Parameter(Mandatory)]
        [hashtable[]]
        $NamespaceConfig
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DfsDsc

    DFSNamespaceServerConfiguration DFSNamespaceConfig
    {
        IsSingleInstance = 'Yes'
        UseFQDN          = $true
    }

    foreach ($namespace in $NamespaceConfig)
    {
        [string]$firstTarget, [string[]]$remainingTargets = $namespace.Targets.Where( {$_}, 'Split', 1)
        DFSNamespaceRoot ('{0}{1}' -f $firstTarget, $namespace.Sharename)
        {
            Path                 = '\\{0}\{1}' -f $DomainFqdn, $namespace.Sharename
            TargetPath           = '\\{0}.{1}\{2}' -f $firstTarget, $DomainFqdn, $namespace.Sharename
            Ensure               = 'Present'
            Type                 = 'DomainV2'
        }

        foreach ($target in $remainingTargets)
        {
            DFSNamespaceRoot ('{0}{1}' -f $target, $namespace.Sharename)
            {
                Path                 = '\\{0}\{1}' -f $DomainFqdn, $namespace.Sharename
                TargetPath           = '\\{0}.{1}\{2}' -f $target, $DomainFqdn, $namespace.Sharename
                Ensure               = 'Present'
                Type                 = 'DomainV2'
            }
        }
    }
}
