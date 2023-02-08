configuration WebVirtualDirectories {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    foreach ($item in $Items)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name
        (Get-DscSplattedResource -ResourceName xWebVirtualDirectory -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
