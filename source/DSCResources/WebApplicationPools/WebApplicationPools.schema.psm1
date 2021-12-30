configuration WebApplicationPools {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    foreach ($item in $Items)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.Name
        (Get-DscSplattedResource -ResourceName xWebAppPool -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
