configuration AddsOrgUnitsAndGroups
{
    param
    (
        [object[]]
        $OrgUnits,

        [object[]]
        $Groups
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc

    $domainDn = lookup AddsDomain/DomainDn

    WaitForADDomain Domain
    {
        DomainName = Lookup AddsDomain/DomainName
    }

    $script:ouDependencies = @()
    
    function Get-OrgUnitSplat
    {
        param
        (
            [Parameter(Mandatory)]
            [object]
            $Object,

            [Parameter(Mandatory)]
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
    
    foreach ($ou in $OrgUnits)
    {
        if (-not $ou.Path) {
            $ou.Path = Lookup -PropertyPath AddsDomain/DomainDn
        }

        if ($ou.Path -notmatch '(?<DomainPart>dc=\w+,dc=\w+)') {
            $ou.Path = "$($ou.Path),$(Lookup -PropertyPath AddsDomain/DomainDn)"
        }

        Get-OrgUnitSplat -Object $ou -ParentPath $ou.Path -SkipDepend
    }

    $dependencies = @()

    foreach ($group in $Groups.Where({$_.groupscope -eq "DomainLocal"}))
    {
        $dependencies += "[ADGroup]'$($group.GroupName)'"
        $group.DependsOn = $ouDependencies
        $group.Path = '{0},{1}' -f $group.Path, $domainDn
        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName "'$($group.GroupName)'" -Properties $group -NoInvoke).Invoke($group)
    }

    foreach ($group in $Groups.Where( {$_.groupscope -eq "Global"}))
    {
        $group.Path = '{0},{1}' -f $group.Path, $domainDn
        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName "'$($group.GroupName)'" -Properties $group -NoInvoke).Invoke($group)
    }
}
