configuration ComputerSettings {
    Param (
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Description,

        [string]$DomainName,

        [string]$WorkGroupName,
        
        [string]$JoinOU,

        [pscredential]$Credential,

        [string]$TimeZone
    )
    
    Import-DscResource -ModuleName ComputerManagementDsc
   
    $timeZoneParamList = 'IsSingleInstance', 'TimeZone', 'DependsOn', 'PsDscRunAsCredential'
    $computerParamList = 'Name', 'Credential', 'DependsOn', 'Description', 'DomainName', 'JoinOU', 'PsDscRunAsCredential', 'Server', 'UnjoinCredential', 'WorkGroupName'
    
    $params = @{ }
    foreach ($item in ($PSBoundParameters.GetEnumerator() | Where-Object Key -in $computerParamList)) {
        $params.Add($item.Key, $item.Value)
    }
    (Get-DscSplattedResource -ResourceName Computer -ExecutionName "Computer$($params.Name)" -Properties $params -NoInvoke).Invoke($params)
    
    $params = @{ }
    foreach ($item in ($PSBoundParameters.GetEnumerator() | Where-Object Key -in $timeZoneParamList)) {
        $params.Add($item.Key, $item.Value)
    }
    $params.Add('IsSingleInstance', 'Yes')
    (Get-DscSplattedResource -ResourceName TimeZone -ExecutionName "TimeZone$($params.Name)" -Properties $params -NoInvoke).Invoke($params)
}
