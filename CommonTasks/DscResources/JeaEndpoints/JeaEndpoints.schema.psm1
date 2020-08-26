configuration JeaEndpoints {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Endpoints
    )

    Import-DscResource -ModuleName JeaDsc

    foreach ($endpoint in $Endpoints)
    {
        if (-not $endpoint.ContainsKey('Ensure'))
        {
            $endpoint.Ensure = 'Present'
        }

        if ($endpoint.RoleDefinitions)
        {
            $endpoint.RoleDefinitions = ConvertTo-Expression -Object $endpoint.RoleDefinitions -Explore
        }
        
        (Get-DscSplattedResource -ResourceName JeaSessionConfiguration -ExecutionName "JeaSessionConfiguration_$($endpoint.Name)" -Properties $endpoint -NoInvoke).Invoke($endpoint)
        
    }

}
