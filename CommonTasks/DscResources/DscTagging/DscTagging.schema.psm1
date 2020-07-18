configuration DscTagging {
    p aram (
        [Parameter(Mandatory)]
        [System.Version]$Version,

        [Parameter(Mandatory)]
        [string]$Environment
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $gitCommitId = git log -n 1 *>&1
    $gitCommitId = if ($gitCommitId -like '*fatal*') {
        'NoGitRepo'
    }
    else {
        $gitCommitId[0].Substring(7)
    }

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
        ValueData = $gitCommitId
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

    xRegistry DscBuildNumber {
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
        ValueName = 'BuildNumber'
        ValueData = ">>$($env:BHBuildNumber)<<" #the format supports finding the BuildNumber without using a MOF parser 
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }
}
