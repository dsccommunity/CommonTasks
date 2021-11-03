configuration PowerShellRepositories
{
    param
    (
        [Hashtable[]]
        $Repositories
    )

    Import-DscResource -ModuleName PowerShellGet

    foreach ($repo in $Repositories)
    {
        (Get-DscSplattedResource -ResourceName PSRepository -ExecutionName "PSRepo$($repo.Name)" -Properties $repo -NoInvoke).Invoke($repo)
    }
}
