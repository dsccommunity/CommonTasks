configuration AddsDomainPrincipals
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $DomainDN,

        [Hashtable[]]
        $Computers,

        [Hashtable[]]
        $Users,

        [Hashtable]
        $KDSKey,

        [Hashtable[]]
        $ManagedServiceAccounts
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    
    function AddMemberOf {
        param (
            [String]   $ExecutionName,
            [String]   $ExecutionType,
            [String]   $AccountName,
            [String[]] $MemberOf
        )

        if( $null -ne $MemberOf -and $MemberOf.Count -gt 0 )
        {
            Script "$($ExecutionName)_MemberOf"
            {
                TestScript = 
                {
                    # get current member groups in MemberOf 
                    $currentGroups = Get-ADPrincipalGroupMembership -Identity $using:AccountName | `
                                     Where-Object { $using:MemberOf -contains $_.SamAccountName } | `
                                     Select-Object -ExpandProperty SamAccountName

                    Write-Verbose "ADPrincipal '$using:AccountName' is member of required groups: $($currentGroups -join ', ')"

                    $missingGroups = $using:MemberOf | Where-Object { -not ($currentGroups -contains $_) }

                    if( $missingGroups.Count -eq 0 )
                    {  
                        return $true
                    }

                    Write-Verbose "ADPrincipal '$using:AccountName' is not member of required groups: $($missingGroups -join ', ')"
                    return $false
                }
                SetScript = 
                {
                    Add-ADPrincipalGroupMembership -Identity $using:AccountName -MemberOf $using:MemberOf
                }
                GetScript = { return 'NA' } 
                DependsOn = "[$ExecutionType]$ExecutionName"
            }            
        }
    }
    
    if( $null -ne $Computers )
    {
        foreach ($computer in $Computers)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $computer = @{}+$computer

            # save group list
            $memberOf = $computer.MemberOf
            $computer.Remove( 'MemberOf' )

            $executionName = "adComputer_$($computer.ComputerName)"

            (Get-DscSplattedResource -ResourceName ADComputer -ExecutionName $executionName -Properties $computer -NoInvoke).Invoke($computer)

            AddMemberOf -ExecutionName $executionName -ExecutionType ADComputer -AccountName "$($computer.ComputerName)$" -MemberOf $memberOf
        }
    }

    if( $null -ne $Users )
    {
        # convert DN to Fqdn
        $pattern = '(?i)DC=(?<name>\w+){1,}?\b'
        $domainName = ([RegEx]::Matches($DomainDN, $pattern) | ForEach-Object { $_.groups['name'] }) -join '.'

        foreach ($user in $Users)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $user = @{}+$user
            
            if( [string]::IsNullOrWhiteSpace($user.DomainName) )
            { 
                $user.DomainName = $domainName
            }

            # save group list
            $memberOf = $user.MemberOf
            $user.Remove( 'MemberOf' )

            $executionName = "adUser_$($user.UserName)"

            (Get-DscSplattedResource -ResourceName ADUser -ExecutionName $executionName -Properties $user -NoInvoke).Invoke($user)

            AddMemberOf -ExecutionName $executionName -ExecutionType ADUser -AccountName $user.UserName -MemberOf $memberOf
        }
    }

    $dependsOnKdsKey = $null

    if( $null -ne $KDSKey )
    {
        (Get-DscSplattedResource -ResourceName ADKDSKey -ExecutionName 'adKDSKey' -Properties $KDSKey -NoInvoke).Invoke($KDSKey)

        $dependsOnKdsKey = '[ADKDSKey]adKDSKey'
    }

    if( $null -ne $ManagedServiceAccounts )
    {
        foreach ($svcAccount in $ManagedServiceAccounts)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $svcAccount = @{}+$svcAccount

            # save group list and computer
            $memberOf = $svcAccount.MemberOf
            $computer = $svcAccount.Computer
            $svcAccount.Remove( 'MemberOf' )
            $svcAccount.Remove( 'Computer' )

            if( $null -ne $dependsOnKdsKey )
            {
                $svcAccount.DependsOn = $dependsOnKdsKey
            }

            $executionName = "adMSA_$($svcAccount.ServiceAccountName)"

            (Get-DscSplattedResource -ResourceName ADManagedServiceAccount -ExecutionName $executionName -Properties $svcAccount -NoInvoke).Invoke($svcAccount)

            # assign a managed service account to AD computer
            if( -not [string]::IsNullOrWhitespace($computer) )
            {
                if( $svcAccount.AccountType -eq 'Standalone' )
                {
                    $svcAccountName = $svcAccount.ServiceAccountName

                    Script "$($executionName)_Computer"
                    {
                        TestScript = 
                        {
                            Write-Verbose "Get managed service accounts hosted by AD computer '$using:computer'..."
                            $svcAccounts = Get-ADComputerServiceAccount -Identity $using:computer -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $svcAccount.ServiceAccountName }

                            if( $null -ne $svcAccounts -and $svcAccounts.Count -ne 1 )
                            {
                                Write-Verbose "OK - managed service account '$using:svcAccountName' is assigned to AD computer '$using:computer'."
                                return $true;
                            }
        
                            Write-Verbose "Managed service account '$using:svcAccountName' is NOT assigned to AD computer '$using:computer'."
                            return $false
                        }
                        SetScript = 
                        {
                            Write-Verbose "Assign managed service account '$using:svcAccountName' to AD computer '$using:computer'"
                            Add-ADComputerServiceAccount -Computer $using:computer -ServiceAccount $using:svcAccountName
                        }
                        GetScript = { return 'NA' } 
                        DependsOn = "[ADManagedServiceAccount]$executionName"
                    }  
                }
                else
                {
                    throw "ERROR: Only a standalone managed service account can be assigned to an AD computer account."
                }          
            }

            # append $ to acoountname to identify it as MSA
            AddMemberOf -ExecutionName $executionName -ExecutionType ADManagedServiceAccount -AccountName "$($svcAccount.ServiceAccountName)$" -MemberOf $memberOf
        }
    }
}
