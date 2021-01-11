configuration Network {
    param (
        [ValidateRange(1, 4)]
        [int]$NetworkZone,

        [Parameter(Mandatory)]
        [int]$MtuSize,

        [string]$InterfaceAlias = 'Ethernet'
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    xScript SetMtuSize {
        GetScript  = {
            $interface = Get-NetIPInterface -InterfaceAlias $using:InterfaceAlias -AddressFamily IPv4 |
            Select-Object -Property InterfaceAlias, NlMtu
            @{
                Result = [System.Management.Automation.PSSerializer]::Serialize($interface)
            }
        }
        TestScript = {
            $state = [scriptblock]::Create($GetScript).Invoke()
            $interface = [System.Management.Automation.PSSerializer]::Deserialize($state.Result)

            $result = $interface.NlMtu -eq $using:MtuSize
            if (-not $result) {
                Write-Verbose "MTU Size is NOT in desired state ($($interface.NlMtu))"
            }
            else {
                Write-Verbose "MTU Size is in desired state ($($interface.NlMtu))"
            }
            return $result
        }
        SetScript  = {
            Set-NetIPInterface -InterfaceAlias $using:InterfaceAlias -NlMtuBytes $using:MtuSize
        }
    }
}
