configuration DhcpScopes
{
    param
    (
        [hashtable[]]
        $Scopes,

        [pscredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    xDhcpServerAuthorization "$($node.Name)_DhcpServerActivation" {
        Ensure               = 'Present'
        PsDscRunAsCredential = $DomainCredential
    }

    foreach ($scope in $Scopes) {
        if (-not $scope.ContainsKey('Ensure')) {
            $scope.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($scope.ScopeId)"
        (Get-DscSplattedResource -ResourceName xDhcpServerScope -ExecutionName $executionName -Properties $scope -NoInvoke).Invoke($scope)
    }
}
