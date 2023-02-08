configuration ScomManagementPacks
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $ManagementPacks
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName cScom

    <#
    Name
    ManagementPackPath
    ManagementPackContent
    #>

    foreach ($manPack in $ManagementPacks)
    {
        $manPack = @{} + $manPack
        if ($manPack.Contains('ManagementPackPath') -and $manPack.Contains('ManagementPackContent'))
        {
            throw '[ScomManagementPacks] Both ManagementPackPath as well as ManagementPackContent specified.'
        }

        $executionName = "scommp_$($manPack.Name)"

        (Get-DscSplattedResource -ResourceName ScomManagementPack -ExecutionName $executionName -Properties $manPack -NoInvoke).Invoke($manPack)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
