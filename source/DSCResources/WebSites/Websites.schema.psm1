configuration WebSites {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    $cimClassParameters = @{
        AuthenticationInfo = 'MSFT_xWebAuthenticationInformation'
        BindingInfo        = 'MSFT_xWebBindingInformation'
        LogCustomFields    = 'MSFT_xLogCustomFieldInformation'
    }

    foreach ($item in $Items)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $item = @{} + $item

        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        foreach ($cimClassParameter in $cimClassParameters.GetEnumerator())
        {
            if ($item.ContainsKey($cimClassParameter.Name))
            {
                $data = $item."$($cimClassParameter.Name)"
                $item."$($cimClassParameter.Name)" = (Get-DscSplattedResource -ResourceName $cimClassParameters."$($cimClassParameter.Name)" -Properties $data -NoInvoke).Invoke($data)
            }
        }

        $executionName = "website_$($item.Name -replace '[{}#\-\s]','_')"
        (Get-DscSplattedResource -ResourceName xWebSite -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
