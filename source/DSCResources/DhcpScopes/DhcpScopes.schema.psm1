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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName xDhcpServer
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

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
