Configuration DscTagging {
    Param(
        [Parameter(Mandatory)]
        [System.Version]$Version,

        [Parameter(Mandatory)]
        [string]$Environment
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    xRegistry DscVersion {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
        ValueName = 'Version'
        ValueData = $Version
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscEnvironment {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
        ValueName = 'Environment'
        ValueData = $Environment
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscGitCommitId {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
        ValueName = 'GitCommitId'
        ValueData = (git show | Select-Object -First 1).Substring(7)
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    xRegistry DscBuildDate {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
        ValueName = 'BuildDate'
        ValueData = Get-Date
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }
}