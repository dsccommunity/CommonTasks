Configuration SecurityBase {
    Param(
        [ValidateSet('DC', 'SqlServer', 'Baseline', 'JumpServer', 'HyperV', 'WebServer', 'FileServer')]
        [string]$Role
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.1.0.0

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