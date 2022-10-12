configuration SharePointProvisioning
{
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $FarmConfigDatabaseName,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $DatabaseServer,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $useSQLAuthentication,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $DatabaseCredentials,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $FarmAccount,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $Passphrase,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.String]
        $AdminContentDatabaseName,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $RunCentralAdmin,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CentralAdministrationUrl,

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateRange(1, 65535)]
        [System.UInt32]
        $CentralAdministrationPort,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        [ValidateSet("NTLM", "Kerberos")]
        $CentralAdministrationAuth,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        [ValidateSet("Application",
            "ApplicationWithSearch",
            "Custom",
            "DistributedCache",
            "Search",
            "SingleServerFarm",
            "WebFrontEnd",
            "WebFrontEndWithDistributedCache")]
        $ServerRole,

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet("Off", "On", "OnDemand")]
        [System.String]
        $DeveloperDashboard,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $ApplicationCredentialKey,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $InstallAccount,

        [Parameter(ParameterSetName='NoDependsOn')]
        [string]
        $CentralAdminServerName,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDSC

    if ($DependsOn -and -not $Config)
    {
        throw "If DependsOn is specified, the configuration must be indented and passed using the Config parameter."
    }

    if ($Config)
    {
        $param = $Config.Clone()
    }
    else
    {
        $param = $PSBoundParameters
        $param.Remove('InstanceName')
        $param.Remove('DependsOn')
    }

    $param['Ensure'] = 'Present'
    $param['IsSingleInstance'] = 'Yes'

    if (-not $CentralAdministrationUrl)
    {
        WaitForAll WaitForFarmCreation
        {
            NodeName         = $CentralAdminServerName
            ResourceName     = "[SPFarm]SharePointFarmCreate::[SharePointProvisioning]"
            RetryIntervalSec = 20
            RetryCount       = 180
        }
        $executionName = 'SharePointFarmJoin'
    }
    else
    {
        $executionName = 'SharePointFarmCreate'
    }

    (Get-DscSplattedResource -ResourceName SPFarm -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)

}
