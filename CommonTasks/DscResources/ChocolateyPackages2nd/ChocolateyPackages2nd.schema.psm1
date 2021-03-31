configuration ChocolateyPackages2nd {
    param (
        [Parameter()]
        [hashtable[]]$Packages
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName Chocolatey

    if( $Packages -ne $null )
    {
        $clonedPackageList = [System.Collections.ArrayList]@()

        [uint16]$i = 0

        # set Rank attribute to allow a later ordering
        foreach ($p in $Packages)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $p = @{}+$p
            # counter to keep original list order on equal rank values
            $i++

            if( [string]::IsNullOrWhiteSpace($p.Rank) )
            {
                # set default Rank to 1000
                $p.Rank = [UInt64](1000 * 100000 + $i)
            }
            else
            {
                $p.Rank = [UInt64]($p.Rank * 100000 + $i)
            }

            $clonedPackageList.Add( $p ) 
        }

        foreach ($p in ($clonedPackageList | Sort-Object {[UInt64]($_.Rank)}) )
        {
            $p.Remove( 'Rank' )

            $executionName = $p.Name -replace '\(|\)|\.| ', ''
            $executionName = "Chocolatey_$executionName"
            $p.ChocolateyOptions = [hashtable]$p.ChocolateyOptions

            if (-not $p.ContainsKey('Ensure')) {
                $p.Ensure = 'Present'
            }

            [boolean]$forceReboot = $false
            if ($p.ContainsKey('ForceReboot')) {
                $forceReboot = $p.ForceReboot
                $p.Remove( 'ForceReboot' )
            }

            (Get-DscSplattedResource -ResourceName ChocolateyPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)

            if ($forceReboot -eq $true)
            {
                $rebootKeyName = 'HKLM:\SOFTWARE\DSC Community\CommonTasks\RebootRequests'
                $rebootVarName = "RebootAfter_$executionName"

                Script $rebootVarName
                {
                    TestScript = {
                        $val = Get-ItemProperty -Path $using:rebootKeyName -Name $using:rebootVarName -ErrorAction SilentlyContinue

                        if ($val -ne $null -and $val.$rebootVarName -gt 0) {
                            return $true
                        }
                        return $false
                    }
                    SetScript = {
                        if( -not (Test-Path -Path $using:rebootKeyName) ) {
                            New-Item -Path $using:rebootKeyName -Force
                        }
                        Set-ItemProperty -Path $rebootKeyName -Name $using:rebootVarName -value 1
                        $global:DSCMachineStatus = 1
                    }
                    GetScript = { return @{result = 'result'}}
                    DependsOn = "[ChocolateyPackage]$executionName"
                }
            }
        }
    }
}
