configuration SharePointProvisioning
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $FarmConfigDatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseServer,

        [Parameter()]
        [System.Boolean]
        $useSQLAuthentication,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DatabaseCredentials,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $FarmAccount,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Passphrase,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AdminContentDatabaseName,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $RunCentralAdmin,

        [Parameter()]
        [System.String]
        $CentralAdministrationUrl,

        [Parameter()]
        [ValidateRange(1, 65535)]
        [System.UInt32]
        $CentralAdministrationPort,

        [Parameter()]
        [System.String]
        [ValidateSet('NTLM', 'Kerberos')]
        $CentralAdministrationAuth,

        [Parameter()]
        [System.String]
        [ValidateSet('Application',
            'ApplicationWithSearch',
            'Custom',
            'DistributedCache',
            'Search',
            'SingleServerFarm',
            'WebFrontEnd',
            'WebFrontEndWithDistributedCache')]
        $ServerRole,

        [Parameter()]
        [ValidateSet('Off', 'On', 'OnDemand')]
        [System.String]
        $DeveloperDashboard,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ApplicationCredentialKey,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter()]
        [string]
        $CentralAdminServerName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    $PSBoundParameters.Add('Ensure', 'Present')
    $PSBoundParameters.Add('IsSingleInstance', 'Yes')
    $PSBoundParameters.Remove('InstanceName')
    $PSBoundParameters.Remove('DependsOn')
    $PSBoundParameters.Remove('PsDscRunAsCredential')
    $PSBoundParameters.Remove('CentralAdminServerName')

    if (-not $CentralAdministrationUrl)
    {
        WaitForAll WaitForFarmCreation
        {
            NodeName         = $CentralAdminServerName
            ResourceName     = '[SPFarm]SharePointFarmCreate::[SharePointProvisioning]'
            RetryIntervalSec = 20
            RetryCount       = 180
        }
        $executionName = 'SharePointFarmJoin'
    }
    else
    {
        $executionName = 'SharePointFarmCreate'
    }

    (Get-DscSplattedResource -ResourceName SPFarm -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)

}
