configuration DscTagging {
    param (
        [Parameter(Mandatory)]
        [System.Version]$Version,

        [Parameter(Mandatory)]
        [string]$Environment,

        [Parameter()]
        [string[]]$Modules
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
        ValueData = "$($env:BHBuildNumber)"
        ValueType = 'String'
        Ensure    = 'Present'
        Force     = $true
    }

    if ($null -ne $Modules -and $Modules.Count -gt 0) {

        # check for duplicate module names
        $ht = @{}
        $Modules | ForEach-Object {$ht["$_"] += 1}
        $ht.Keys | Where-Object {$ht["$_"] -gt 1} | ForEach-Object { throw "ERROR: DscTagging: Duplicate module name '$_' found." }

        xRegistry DscModules {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\DscTagging'
            ValueName = 'Modules'
            ValueData = $Modules
            ValueType = 'MultiString'
            Ensure    = 'Present'
            Force     = $true
        }
    }
}
