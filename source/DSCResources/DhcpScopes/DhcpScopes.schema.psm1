configuration DhcpScopes
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Scopes,

        [Parameter()]
        [pscredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName DhcpServerDsc
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    if ($DomainCredential)
    {
        xDhcpServerAuthorization "$($node.Name)_DhcpServerActivation"
        {
            Ensure               = 'Present'
            PsDscRunAsCredential = $DomainCredential
            IsSingleInstance     = 'Yes'
        }
    }

    foreach ($scope in $Scopes)
    {
        if (-not $scope.ContainsKey('Ensure'))
        {
            $scope.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($scope.ScopeId)"
        (Get-DscSplattedResource -ResourceName xDhcpServerScope -ExecutionName $executionName -Properties $scope -NoInvoke).Invoke($scope)
    }
}
