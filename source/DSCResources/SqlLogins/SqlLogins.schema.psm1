configuration SqlLogins {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
    )

    <#
    InstanceName = [string]
    Name = [string]
    [DefaultDatabase = [string]]
    [DependsOn = [string[]]]
    [Disabled = [bool]]
    [Ensure = [string]{ Absent | Present }]
    [LoginCredential = [PSCredential]]
    [LoginMustChangePassword = [bool]]
    [LoginPasswordExpirationEnabled = [bool]]
    [LoginPasswordPolicyEnforced = [bool]]
    [LoginType = [string]{ AsymmetricKey | Certificate | ExternalGroup | ExternalUser | SqlLogin | WindowsGroup | WindowsUser }]
    [PsDscRunAsCredential = [PSCredential]]
    [ServerName = [string]]
    #>

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName SqlServerDsc -Name SqlLogin

    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if (-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlLogin -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
