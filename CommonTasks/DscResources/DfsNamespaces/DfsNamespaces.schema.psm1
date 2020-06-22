configuration DfsNamespaces
{
    param
    (
        [hashtable[]]
        $NamespaceConfig,

        [pscredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName DfsDsc
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    $DomainFqdn = Lookup AddsDomain/DomainFqdn
    $DomainCredential = Lookup AddsDomain/DomainAdministrator

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
            PsDscRunAsCredential = $DomainCredential
        }

        foreach ($target in $remainingTargets)
        {
            DFSNamespaceRoot ('{0}{1}' -f $target, $namespace.Sharename)
            {
                Path                 = '\\{0}\{1}' -f $DomainFqdn, $namespace.Sharename
                TargetPath           = '\\{0}.{1}\{2}' -f $target, $DomainFqdn, $namespace.Sharename
                Ensure               = 'Present'
                Type                 = 'DomainV2'
                PsDscRunAsCredential = $DomainCredential
            }
        }
    }
}
