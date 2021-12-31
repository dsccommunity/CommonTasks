configuration PowerShellRepositories
{
    param
    (
        [Parameter()]
        [Hashtable[]]
        $Repositories
    )

    Import-DscResource -ModuleName PowerShellGet -ModuleVersion 2.2.5

    foreach ($repo in $Repositories)
    {
        (Get-DscSplattedResource -ResourceName PSRepository -ExecutionName "PSRepo$($repo.Name)" -Properties $repo -NoInvoke).Invoke($repo)
    }
}
