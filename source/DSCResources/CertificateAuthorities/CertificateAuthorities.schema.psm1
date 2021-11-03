configuration CertificateAuthorities {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [ValidateSet('EnterpriseRootCA', 'EnterpriseSubordinateCA', 'StandaloneRootCA', 'StandaloneSubordinateCA')]
        [System.String]
        $CAType,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $CACommonName,

        [Parameter()]
        [System.String]
        $CADistinguishedNameSuffix,

        [Parameter()]
        [System.String]
        $CertFile,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertFilePassword,

        [Parameter()]
        [System.String]
        $CertificateID,

        [Parameter()]
        [System.String]
        $CryptoProviderName,

        [Parameter()]
        [System.String]
        $DatabaseDirectory,

        [Parameter()]
        [System.String]
        $HashAlgorithmName,

        [Parameter()]
        [System.Boolean]
        $IgnoreUnicode,

        [Parameter()]
        [System.String]
        $KeyContainerName,

        [Parameter()]
        [System.UInt32]
        $KeyLength,

        [Parameter()]
        [System.String]
        $LogDirectory,

        [Parameter()]
        [System.String]
        $OutputCertRequestFile,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingCAinDS,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingDatabase,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingKey,

        [Parameter()]
        [System.String]
        $ParentCA,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ActiveDirectoryCSDsc

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

    if (-not $PSBoundParameters.ContainsKey('Ensure')) {
        $PSBoundParameters.Add('Ensure', 'Present')
    }
    $PSBoundParameters.Remove('InstanceName')
 
    $executionName = 'CaDeployment'
    (Get-DscSplattedResource -ResourceName AdcsCertificationAuthority -ExecutionName $executionName -Properties $PSBoundParameters -NoInvoke).Invoke($PSBoundParameters)
    
}