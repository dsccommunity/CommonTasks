configuration SqlServer
{
    param
    (
        [Parameter()]
        [hashtable]
        $Setup
    )

    Import-DscResource -ModuleName SqlServerDsc

    if( $Setup -ne $null ) {
        (Get-DscSplattedResource -ResourceName SqlSetup -ExecutionName "sqlSetup" -Properties $Setup -NoInvoke).Invoke($Setup)
    }
}
