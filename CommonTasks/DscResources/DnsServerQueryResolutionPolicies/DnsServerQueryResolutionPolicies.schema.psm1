configuration DnsServerQueryResolutionPolicies
{
    param
    (
        [Parameter(Mandatory)]
        [Hashtable[]]
        $Policies
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($dnsPol in $Policies)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $dnsPol = @{}+$dnsPol

        $name   = $dnsPol.Name
        $action = $dnsPol.Action
        $fqdn   = $dnsPol.Fqdn

        Script "dnsQueryPol_$($name)"
        {
            TestScript = {
                $val = Get-DnsServerQueryResolutionPolicy -Name $using:name -ErrorAction SilentlyContinue

                Write-Verbose "Test DNS query policy '$using:name' -> expect Action: '$using:action', FQDN '$using:fqdn'"
                Write-Verbose "Current Values:  Action: '$($val.Action)'"

                if ($null -ne $val -and $val.Action -eq $using:action)
                {
                    $critType = $val.Criteria.CriteriaType
                    $critVal  = $val.Criteria.Criteria

                    Write-Verbose "Current Values:  $($critType): '$critVal'"

                    # FQDN ends with . -> this character is added by Add/Set function if not present in YAML FQDN definition
                    if( $critType -eq 'Fqdn' -and
                        (($critVal -eq $using:fqdn) -or 
                         ($critVal.EndsWith('.') -and ($critVal.Substring(0, $critVal.Length - 1)) -eq $using:fqdn)) ) 
                    { 
                        return $true
                    }
                }   

                Write-Verbose "Differences found."
                return $false
            }
            SetScript = {      
                $val = Get-DnsServerQueryResolutionPolicy -Name $using:name -ErrorAction SilentlyContinue

                if ($null -eq $val)
                {
                    Write-Verbose "Add DNS query policy '$using:name' with Action: '$using:action', FQDN '$using:fqdn'"
                    Add-DnsServerQueryResolutionPolicy -Name $using:name -Action $using:action -Fqdn $using:fqdn
                }
                else
                {
                    Write-Verbose "Update DNS query policy '$using:name' with Action: '$using:action', FQDN '$using:fqdn'"
                    Set-DnsServerQueryResolutionPolicy -Name $using:name -Action $using:action -Fqdn $using:fqdn                        
                }
            }
            GetScript = { return @{result = 'N/A'}}
        }            
    }
}
