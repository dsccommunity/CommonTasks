configuration AddsProtectFromAccidentalDeletion
{
    param
    (
        [Parameter()]
        [Boolean]
        $ProtectDomain = $false,
        
        [Parameter()]
        [Boolean]
        $ProtectOrgUnit = $false,
        
        [Parameter()]
        [String]
        $FilterOrgUnit = '*',
        
        [Parameter()]
        [Boolean]
        $ProtectUser = $false,
        
        [Parameter()]
        [String]
        $FilterUser = '*',
        
        [Parameter()]
        [Boolean]
        $ProtectGroup = $false,
        
        [Parameter()]
        [String]
        $FilterGroup = '*',
        
        [Parameter()]
        [Boolean]
        $ProtectComputer = $false,
        
        [Parameter()]
        [String]
        $FilterComputer = '*',
        
        [Parameter()]
        [Boolean]
        $ProtectFineGrainedPasswordPolicy = $false,
        
        [Parameter()]
        [String]
        $FilterFineGrainedPasswordPolicy = '*',
        
        [Parameter()]
        [Boolean]
        $ProtectReplicationSite = $false,
        
        [Parameter()]
        [String]
        $FilterReplicationSite = '*'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    if( $ProtectDomain -eq $true )
    {
        Script AddsProtectADDomain
        {
            TestScript = {
                $cnt = (Get-ADDomain | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADDomains: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADDomain | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectOrgUnit -eq $true )
    {
        Script AddsProtectOrgUnit
        {
            TestScript = {
                $cnt = (Get-ADOrganizationalUnit -Filter $using:FilterOrgUnit | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADOrganizationalUnits: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADOrganizationalUnit -Filter $using:FilterOrgUnit | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectUser -eq $true )
    {
        Script AddsProtectUser
        {
            TestScript = {
                $cnt = (Get-ADUser -Filter $using:FilterUser | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADUsers: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADUser -Filter $using:FilterUser | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectGroup -eq $true )
    {
        Script AddsProtectGroup
        {
            TestScript = {
                $cnt = (Get-ADGroup -Filter $using:FilterGroup | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADGroups: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADGroup -Filter $using:FilterGroup | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectComputer -eq $true )
    {
        Script AddsProtectComputer
        {
            TestScript = {
                $cnt = (Get-ADComputer -Filter $using:FilterComputer | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADComputers: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADComputer -Filter $using:FilterComputer | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectFineGrainedPasswordPolicy -eq $true )
    {
        Script AddsProtectFineGrainedPasswordPolicy
        {
            TestScript = {
                $cnt = (Get-ADFineGrainedPasswordPolicy -Filter $using:FilterFineGrainedPasswordPolicy | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADFineGrainedPasswordPolicies: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADFineGrainedPasswordPolicy -Filter $using:FilterFineGrainedPasswordPolicy | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }

    if( $ProtectReplicationSite -eq $true )
    {
        Script AddsProtectReplicationSite
        {
            TestScript = {
                $cnt = (Get-ADReplicationSite -Filter $using:FilterReplicationSite | `
                        Get-ADObject -Properties ProtectedFromAccidentalDeletion | `
                        Where-Object { $_.ProtectedFromAccidentalDeletion -ne $true } | `
                        Measure-Object).Count

                Write-Verbose "Unprotected ADReplicationSites: $cnt"
 
                return ($cnt -eq 0)
            }
            SetScript = {      
                Get-ADReplicationSite -Filter $using:FilterReplicationSite | Set-ADObject -ProtectedFromAccidentalDeletion $true
            }
            GetScript = { return @{result = 'N/A'} }
        }            
    }
}
