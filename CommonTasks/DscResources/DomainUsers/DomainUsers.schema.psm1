configuration DomainUsers
{
    param
    (
        [hashtable[]]
        $Users
    )

    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.0.1
    $domainName = lookup Domain/DomainName

    foreach ($user in $Users)
    {
        if ([string]::IsNullOrWhiteSpace($user.UserName)) { continue }

        $user.DomainName = $domainName
        (Get-DscSplattedResource -ResourceName ADUser -ExecutionName $user.UserName -Properties $user -NoInvoke).Invoke($user)
    }
}
