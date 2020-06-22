configuration AdOrgUnitsAndGroups
{
    param
    (
        [object[]]
        $OrgUnits,

        [object[]]
        $Groups,

        $Node
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc

    $domainDn = lookup Domain/DomainDn

    WaitForADDomain Domain
    {
        DomainName = Lookup Domain/DomainName
    }

    $script:ouDependencies = @()
    
    function Get-OrgUnitSplat
    {
        param
        (
            [object]
            $Object,

            [string]
            $ParentPath,

            [switch]
            $SkipDepend
        )

        $ouPath = 'OU={0},{1}' -f $Object.Name, $ParentPath
        if ($Object.ChildOu.Count -gt 0)
        {
            foreach ($ou in $Object.ChildOu)
            {
                Get-OrgUnitSplat $ou $ouPath
            }
        }

        $Object.Path = $ParentPath
        $script:ouDependencies += "[ADOrganizationalUnit]$($ouPath -Replace ',|=')"
        
        if ($SkipDepend)
        {
            ADOrganizationalUnit ($ouPath -Replace ',|=')
            {
                Name      = $Object.Name
                Path      = $Object.Path
                DependsOn = '[WaitForADDomain]Domain'
            }
        }
        else
        {
            ADOrganizationalUnit ($ouPath -Replace ',|=')
            {
                Name      = $Object.Name
                Path      = $Object.Path
                DependsOn = "[ADOrganizationalUnit]$($ParentPath -Replace ',|=')"
            }
        }        
    }
    
    foreach ($ou in $AdOrgUnits)
    {
        Get-OrgUnitSplat $ou $ou.Path -SkipDepend
    }

    $dependencies = @()

    foreach ($group in $Groups.Where( {$_.groupscope -eq "DomainLocal"}))
    {
        $dependencies += "[adgroup]$($group.GroupName)"
        $group.DependsOn = $ouDependencies
        $group.Path = '{0},{1}' -f $group.Path, $domainDn
        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName $group.GroupName -Properties $group -NoInvoke).Invoke($group)
    }

    foreach ($group in $Groups.Where( {$_.groupscope -eq "Global"}))
    {
        $group.Path = '{0},{1}' -f $group.Path, $domainDn
        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName $group.GroupName -Properties $group -NoInvoke).Invoke($group)
    }
}
