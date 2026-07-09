configuration AddsOrgUnitsAndGroups
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $DomainDN,

        [Parameter()]
        [Hashtable[]]
        $OrgUnits,

        [Parameter()]
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
            [Parameter(Mandatory = $true)]
            [object]
            $Object,

            [Parameter(Mandatory = $true)]
            [string]
            $ParentPath,

            [Parameter()]
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
        $script:ouDependencies += "[ADOrganizationalUnit]$($ouPath -Replace '\W')"

        if ($SkipDepend)
        {
            ADOrganizationalUnit ($ouPath -replace '\W')
            {
                Name      = $Object.Name
                Path      = $Object.Path
                DependsOn = '[WaitForADDomain]Domain'
            }
        }
        else
        {
            ADOrganizationalUnit ($ouPath -replace '\W')
            {
                Name      = $Object.Name
                Path      = $Object.Path
                DependsOn = "[ADOrganizationalUnit]$($ParentPath -Replace '\W')"
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

    foreach ($group in $Groups)
    {
        # remove case sensitivity from hashtables
        $group = @{} + $group

        if ($group.GroupScope -eq 'DomainLocal')
        {
            $dependencies += "[ADGroup]'$($group.GroupName)'"
            $group.DependsOn = $ouDependencies
            $group.Path = '{0},{1}' -f $group.Path, $DomainDn
        }
        elseif (($group.GroupScope -eq 'Global') -or (-not [string]::IsNullOrWhiteSpace($group.Path)))
        {
            $group.Path = '{0},{1}' -f $group.Path, $DomainDn
        }

        (Get-DscSplattedResource -ResourceName ADGroup -ExecutionName $group.GroupName -Properties $group -NoInvoke).Invoke($group)
    }

    # --- Completion anchor -------------------------------------------------
    # A single, always-in-desired-state resource that depends on every OU and
    # group this composite creates. Consumers that must run only AFTER all
    # OUs/groups exist (e.g. AddsDomainPrincipals, which places users into OUs
    # and adds group memberships) should depend on THIS ONE resource via a
    # cross-composite reference:
    #
    #   [Script]AddsOrgUnitsAndGroupsComplete::[AddsOrgUnitsAndGroups]AddsOrgUnitsAndGroups
    #
    # instead of on the composite as a whole. A DependsOn on the whole composite
    # reference expands to references to EVERY member resource (hundreds of
    # OUs + groups); and when that DependsOn is placed on a *consuming composite*
    # DSC propagates it to EVERY resource that composite emits. The two multiply
    # into an O(consumers x members) explosion that bloats the node MOF by tens
    # of MB and exceeds the hard ~10 MB LCM push limit (MI RESULT 27).
    if ($OrgUnits -or $Groups)
    {
        # Group resources are created with ExecutionName = $group.GroupName, so
        # their resource IDs are [ADGroup]<GroupName>; mirror that here. OU refs
        # are already collected in $script:ouDependencies by Get-OrgUnitSplat.
        $groupResourceRefs = foreach ($group in $Groups)
        {
            "[ADGroup]$($group.GroupName)"
        }

        # Filter empties so an absent OU or group set never injects a blank ref.
        $anchorDependencies = @($script:ouDependencies) + @($groupResourceRefs) |
            Where-Object { $_ }

        Script AddsOrgUnitsAndGroupsComplete
        {
            TestScript = { $true }
            SetScript  = { }
            GetScript  = { return @{ Result = 'Complete' } }
            DependsOn  = $anchorDependencies
        }
    }
}
