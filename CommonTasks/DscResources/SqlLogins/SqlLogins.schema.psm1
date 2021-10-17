configuration SqlLogins {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Values
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
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($value in $Values) 
    {
        if(-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        if(-not $value.Ensure)
        {
            $value.Ensure = 'Present'
        }

        $executionName = "$($value.InstanceName)_$($value.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlLogin -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)
    }
}
