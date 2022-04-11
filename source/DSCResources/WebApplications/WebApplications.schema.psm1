configuration WebApplications {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    $dscResourceName = 'xWebApplication'

    foreach ($item in $Items)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $item = @{} + $item

        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        foreach ($key in $item.Clone().Keys)
        {
            foreach ($subItem in $item.$key)
            {
                $scriptBlock = Get-DscCimInstanceReference -ResourceName $dscResourceName -Parameter $key -Data $subItem
                if ($scriptBlock)
                {
                    $result = $scriptBlock.Invoke($subItem)
                    $item[$key] = $result
                }
            }
        }

        $executionName = "webapp_$($item.Name -replace '[{}#\-\s]','_')"
        (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
