configuration DnsServerResponseRateLimiting
{
    param
    (
        [Parameter()]
        [ValidateSet( 'Enable', 'Disable', 'LogOnly')]
        [String]
        $Mode = 'Enable',

        [Parameter()]
        [Uint32]
        $ErrorsPerSec,

        [Parameter()]
        [Uint32]
        $ResponsesPerSec,

        [Parameter()]
        [Hashtable[]]
        $Exceptions
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $RrlParams = @{
        Mode  = $Mode
    }
    if( $ErrorsPerSec -gt 0 ) { $RrlParams.ErrorsPerSec = $ErrorsPerSec }
    if( $ResponsesPerSec -gt 0) { $RrlParams.ResponsesPerSec = $ResponsesPerSec }

    Script 'SetupDnsRRL'
    {
        TestScript = {
            $val = Get-DnsServerResponseRateLimiting -ErrorAction SilentlyContinue

            Write-Verbose "Expected RRL paramters: $($using:RrlParams | Out-String)"
            Write-Verbose "Current  RRL paramters: $($val | Out-String)"

            if ($val -ne $null -and 
                $val.Mode -eq $using:RrlParams.Mode -and
                ($null -eq $using:RrlParams.ErrorsPerSec -or $val.ErrorsPerSec -eq $using:RrlParams.ErrorsPerSec) -and
                ($null -eq $using:RrlParams.ResponsesPerSec -or $val.ResponsesPerSec -eq $using:RrlParams.ResponsesPerSec) )
            { 
                return $true
            }   

            Write-Verbose "Differences found."
            return $false
        }
        SetScript = {      
            $rrlSetParams       = $using:RrlParams
            $rrlSetParams.Force = $true
            Set-DnsServerResponseRateLimiting @rrlSetParams
        }
        GetScript = { return @{result = 'N/A'}}
    }            

    if( $null -ne $Exceptions )
    {
        foreach ($exList in $Exceptions)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $exList = @{}+$exList

            $name = $exList.Name
            $fqdn = $exList.Fqdn

            Script "dnsRrlException_$($name)"
            {
                TestScript = {
                    $val = Get-DnsServerResponseRateLimitingExceptionlist -Name $using:name -ErrorAction SilentlyContinue

                    Write-Verbose "Test RRL exception list '$using:name' -> expect FQDN '$using:fqdn'"
                    Write-Verbose "Current FQDN: '$($val.Fqdn)'"

                    if ($null -ne $val )
                    {
                        # FQDN ends with . -> this character is added by Add/Set function if not present in YAML FQDN definition
                        if( ($val.Fqdn -eq $using:fqdn) -or 
                            ($val.Fqdn.EndsWith('.') -and ($val.Fqdn.Substring(0, $val.Fqdn.Length - 1)) -eq $using:fqdn) ) 
                        { 
                            return $true
                        }
                    }   

                    Write-Verbose "Differences found."
                    return $false
                }
                SetScript = {      
                    $val = Get-DnsServerResponseRateLimitingExceptionlist -Name $using:name -ErrorAction SilentlyContinue
    
                    if ($null -eq $val)
                    {
                        Write-Verbose "Add RRL exception list '$using:name' with FQDN '$using:fqdn'"
                        Add-DnsServerResponseRateLimitingExceptionlist -Name $using:name -Fqdn $using:fqdn
                    }
                    else
                    {
                        Write-Verbose "Update RRL exception list '$using:name' with FQDN '$using:fqdn'"
                        Set-DnsServerResponseRateLimitingExceptionlist -Name $using:name -Fqdn $using:fqdn                        
                    }
                }
                GetScript = { return @{result = 'N/A'}}
            }            
        }
    }
}
