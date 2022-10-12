configuration CertificateAuthorities {
    [CmdletBinding(DefaultParameterSetName='NoDependsOn')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [ValidateSet('EnterpriseRootCA', 'EnterpriseSubordinateCA', 'StandaloneRootCA', 'StandaloneSubordinateCA')]
        [System.String]
        $CAType,

        [Parameter(Mandatory = $true, ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CACommonName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CADistinguishedNameSuffix,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CertFile,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Management.Automation.PSCredential]
        $CertFilePassword,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CertificateID,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $CryptoProviderName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $DatabaseDirectory,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $HashAlgorithmName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $IgnoreUnicode,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $KeyContainerName,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $KeyLength,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $LogDirectory,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $OutputCertRequestFile,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OverwriteExistingCAinDS,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OverwriteExistingDatabase,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.Boolean]
        $OverwriteExistingKey,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.String]
        $ParentCA,

        [Parameter(ParameterSetName='NoDependsOn')]
        [ValidateSet('Hours', 'Days', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter(ParameterSetName='NoDependsOn')]
        [System.UInt32]
        $ValidityPeriodUnits,

        [Parameter(ParameterSetName='DependsOn')]
        [hashtable]
        $Config
    )

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ActiveDirectoryCSDsc

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

    if (-not $param.ContainsKey('Ensure'))
    {
        $param.Add('Ensure', 'Present')
    }

    WindowsFeature ADCS-Cert-Authority
    {
        Ensure = 'Present'
        Name   = 'ADCS-Cert-Authority'
    }

    WindowsFeature ADCS-Cert-Management
    {
        Ensure = 'Present'
        Name   = 'RSAT-ADCS-Mgmt'
    }

    $executionName = 'CaDeployment'
    (Get-DscSplattedResource -ResourceName AdcsCertificationAuthority -ExecutionName $executionName -Properties $param -NoInvoke).Invoke($param)

}
