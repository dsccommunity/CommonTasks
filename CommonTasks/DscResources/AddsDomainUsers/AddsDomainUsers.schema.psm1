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
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $user = @{}+$user
        
        if ([string]::IsNullOrWhiteSpace($user.UserName)) { continue }

        if (-not $user.DomainName -and $domainName)
        {
            $user.DomainName = $domainName
        }

        # save group list
        $memberOf = $user.MemberOf
        $user.Remove( 'MemberOf' )

        $executionName = "adUsr_$($user.UserName)"

        (Get-DscSplattedResource -ResourceName ADUser -ExecutionName $executionName -Properties $user -NoInvoke).Invoke($user)

        if( $null -ne $memberOf -and $memberOf.Count -gt 0 )
        {
            $userName = $user.UserName

            Script "$($executionName)_MemberOf"
            {
                TestScript = 
                {
                    # get current member groups in MemberOf 
                    $currentGroups = Get-ADPrincipalGroupMembership -Identity $using:userName | `
                                     Where-Object { $using:memberOf -contains $_.SamAccountName } | `
                                     Select-Object -ExpandProperty SamAccountName

                    Write-Verbose "User '$using:userName' is member of required groups: $($currentGroups -join ', ')"

                    $missingGroups = $using:memberOf | Where-Object { -not ($currentGroups -contains $_) }

                    if( $missingGroups.Count -eq 0 )
                    {  
                        return $true
                    }

                    Write-Verbose "User '$using:userName' is not member of required groups: $($missingGroups -join ', ')"
                    return $false
                }
                SetScript = 
                {
                    Add-ADPrincipalGroupMembership -Identity $using:userName -MemberOf $using:memberOf
                }
                GetScript = { return 'NA' } 
                DependsOn = "[ADUser]$executionName"  
            }            
        }
    }
}
