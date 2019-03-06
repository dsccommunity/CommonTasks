Configuration ConfigurationBase {
    Param(
        [ValidateSet('DC', 'SqlServer', 'MemberServer', 'JumpServer')]
        [string]$SystemType
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.5.0.0
    #Removing cMicrosoftUpdate and configuration items as long as the module is not on the PSGallery
    #Import-DscResource -ModuleName cMicrosoftUpdate -ModuleVersion 0.0.0.1

    xRegistry EnableRdp {
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server'
        ValueName = 'fDenyTSConnection'
        ValueData = 0
        ValueType = 'Dword'
        Ensure    = 'Present'
    }

    #cWSUSEnable WSUSEnabled {
    #    Enable = 'True'
    #}

    #cWSUSSetServer WSUSServer
    #{
    #    Url    = 'SomeServer'
    #    Ensure = 'Present'
    #}

    #cWSUSInstallDay WSUSInstallDay
    #{
    #    Day    = 'Tuesday'
    #    Ensure = 'Present'
    #}

    #cWSUSInstallTime WSUSInstallTime
    #{
    #    Time   = 5
    #    Ensure = 'Present'
    #}
}