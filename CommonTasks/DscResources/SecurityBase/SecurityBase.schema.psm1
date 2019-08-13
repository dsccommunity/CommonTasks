Configuration SecurityBase {
    Param(
        [ValidateSet('Baseline', 'WebServer', 'FileServer')]
        [string]$Role
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    #Baseline
    xWindowsFeature DisableSmbV1 {
        Name   = 'FS-SMB1'
        Ensure = 'Absent'
    }

    PowerShellExecutionPolicy ExecutionPolicyAllSigned {
        ExecutionPolicyScope = 'LocalMachine'
        ExecutionPolicy      = 'RemoteSigned'
    }
    
    #FileServer
    if ($Role -eq 'FileServer') {
        xRegistry LmCompatibilityLevel5 {
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa'
            ValueName = 'LmCompatibilityLevel'
            ValueData = 5
            ValueType = 'Dword'
            Ensure    = 'Present'
            Force     = $true
        }
    }

    #Web Server
    if ($Role -eq 'WebServer') {
        xRegistry LmCompatibilityLevel4 {
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa'
            ValueName = 'LmCompatibilityLevel'
            ValueData = 4
            ValueType = 'Dword'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}
