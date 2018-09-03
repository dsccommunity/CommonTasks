Configuration SecurityBase {
    Param(
        [ValidateSet('DC', 'SqlServer', 'MemberServer', 'JumpServer')]
        [string]$SystemType
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration, ComputerManagementDsc

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

    xWindowsFeature DisableSmbV1
    {
        Name = 'FS-SMB1'
        Ensure = 'Absent'
    }
}