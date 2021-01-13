configuration AddsDomainUsers
{
    param
    (
        [hashtable[]]
        $Users
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    
    $domainName = lookup AddsDomain/DomainName -DefaultValue $null

    foreach ($user in $Users)
    {
        if ([string]::IsNullOrWhiteSpace($user.UserName)) { continue }

        if (-not $user.DomainName -and $domainName)
        {
            $user.DomainName = $domainName
        }
        (Get-DscSplattedResource -ResourceName ADUser -ExecutionName $user.UserName -Properties $user -NoInvoke).Invoke($user)
    }
}
