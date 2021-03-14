configuration AddsOrgUnitsAndGroups
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $DomainDN,

        [Hashtable[]]
        $OrgUnits,

        [Hashtable[]]
        $Groups
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc

    # convert DN to Fqdn
    $pattern = '(?i)DC=(?<name>\w+){1,}?\b'
    $domainName = ([RegEx]::Matches($DomainDN, $pattern) | ForEach-Object { $_.groups['name'] }) -join '.'

    WaitForADDomain Domain
    {
        DomainName = $domainName
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
        if ( [string]::IsNullOrWhitespace($ou.Path) )
        {
            $ou.Path = $DomainDN
        }

        if ($ou.Path -notmatch '(?<DomainPart>dc=\w+,dc=\w+)')
        {
            $ou.Path = "$($ou.Path),$DomainDN"
        }

        Get-OrgUnitSplat -Object $ou -ParentPath $ou.Path -SkipDepend
    }

    $dependencies = @()

    foreach( $group in $Groups )
    {
        # remove case sensitivity from hashtables
        $group = @{}+$group

        if( $group.GroupScope -eq "DomainLocal" )
        {
            $dependencies += "[ADGroup]'$($group.GroupName)'"
            $group.DependsOn = $ouDependencies
            $group.Path = '{0},{1}' -f $group.Path, $DomainDn
        }
        elseif( ($group.GroupScope -eq "Global") -or (-not [string]::IsNullOrWhiteSpace($group.Path)) )
        {
            $group.Path = '{0},{1}' -f $group.Path, $DomainDn
        }

        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName "'$($group.GroupName)'" -Properties $group -NoInvoke).Invoke($group)
    }
}
