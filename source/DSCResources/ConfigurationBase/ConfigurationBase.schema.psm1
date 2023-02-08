configuration ConfigurationBase {
    param (
        [Parameter()]
        [ValidateSet('Baseline', 'WebServer', 'FileServer')]
        [string]$SystemType
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    xRegistry EnableRdp
    {
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server'
        ValueName = 'fDenyTSConnection'
        ValueData = 0
        ValueType = 'Dword'
        Ensure    = 'Present'
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
