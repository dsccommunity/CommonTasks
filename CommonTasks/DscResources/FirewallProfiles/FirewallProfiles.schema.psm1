Configuration FirewallProfiles {
    Param(
        [Parameter(Mandatory)]
        [string[]]$Profile,

        [string]$Enabled

    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    [void]$PSBoundParameters.Remove('Profile')
    $FirewallProfilesParamList = 'Name', 'Enabled', 'DependsOn', 'PsDscRunAsCredential'
    
    foreach ($Name in $Profile)
    {

    if ($PSBoundParameters.ContainsKey('Name')){ [void]$PSBoundParameters.Remove('Name')  }
    $PSBoundParameters.Add('Name', $Name)    
    $params = @{ }
    foreach ($item in ($PSBoundParameters.GetEnumerator() | Where-Object Key -in $FirewallProfilesParamList)) {
        $params.Add($item.Key, $item.Value)
    }
    (Get-DscSplattedResource -ResourceName FirewallProfile -ExecutionName "FirewallProfiles$($params.Name)" -Properties $params -NoInvoke).Invoke($params)
    }
  
 




}

