Configuration SecurityBase {
    Param(
        [ValidateSet('DC', 'SqlServer', 'Baseline', 'JumpServer', 'HyperV', 'WebServer', 'FileServer')]
        [string]$Role
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    xRegistry LmCompatibilityLevel5 {
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa'
        ValueName = 'LmCompatibilityLevel'
        ValueData = 5
        ValueType = 'Dword'
        Ensure    = 'Present'
    }

    PowerShellExecutionPolicy ExecutionPolicyAllSigned {
        ExecutionPolicyScope = 'LocalMachine'
        ExecutionPolicy      = 'RemoteSigned'
    }

    xWindowsFeature DisableSmbV1 {
        Name   = 'FS-SMB1'
        Ensure = 'Absent'
    }
}