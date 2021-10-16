configuration SqlLogins {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Logins
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

    foreach ($login in $Logins) 
    {
        if(-not $login.InstanceName)
        {
            $login.InstanceName = $DefaultInstanceName
        }

        if(-not $login.Ensure)
        {
            $login.Ensure = 'Present'
        }

        $executionName = "$($login.InstanceName)_$($login.Name -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlLogin -ExecutionName $executionName -Properties $login -NoInvoke).Invoke($login)
    }
}
