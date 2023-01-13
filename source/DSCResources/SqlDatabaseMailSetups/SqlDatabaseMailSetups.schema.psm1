configuration SqlDatabaseMailSetups {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $MailSetups
    )

    <#
    DefaultInstanceName: MSSQLSERVER
    MailSetups: [hashtable[]]
        - ServerName: 'Servername' (Get-ComputerName) [System.String] Mandatory
          InstanceName: 'DSCSQLTEST' [String]
          AccountName : 'MyMail' [String] Mandatory
          ProfileName : 'MyMailProfile' [String] Mandatory
          EmailAddress: 'NoReply@company.local' [String] Mandatory
          ReplyToAddress: 'NoReply@company.local' [String]
          DisplayName : 'mail.company.local' [String]
          MailServerName: 'mail.company.local' [String]
          Description : 'Default mail account and profile.' [String]
          LoggingLevel: 'Normal' [String]
          TcpPort: 25 [String]
    #>

    Import-DscResource -ModuleName SqlServerDsc -Name SqlDatabaseMail

    foreach ($setup in $MailSetups)
    {
        if (-not $setup.InstanceName)
        {
            $setup.InstanceName = $DefaultInstanceName
        }

        $executionName = "SqlMailProfile_$($setup.Servername)_$($setup.InstanceName)_$($setup.AccountName)"
        (Get-DscSplattedResource -ResourceName SqlDatabaseMail -ExecutionName $executionName -Properties $setup -NoInvoke).Invoke($setup)
    }
}
