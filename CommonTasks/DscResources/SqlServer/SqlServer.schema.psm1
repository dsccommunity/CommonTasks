configuration SqlServer
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable]
        $Setup
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SqlServerDsc

    if( $null -ne $Setup )
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $Setup = @{}+$Setup

        # FileStreamAccessLevel is not supported by SqlSetup and must be enabled later
        $fileStreamAccessLevel = $Setup.FileStreamAccessLevel
        $Setup.Remove( 'FileStreamAccessLevel' )

        (Get-DscSplattedResource -ResourceName SqlSetup -ExecutionName "sqlSetup" -Properties $Setup -NoInvoke).Invoke($Setup)

        # enable/disable FileStream
        if( $null -ne $fileStreamAccessLevel )
        {        
            [string]$instanceName = $Setup.InstanceName

            Script sqlFileStreamAccess
            {
                TestScript = 
                {
                    # get installed SQL Server version
                    [string]$cmgmt = (Get-CimInstance -NameSpace 'ROOT\Microsoft\SQLServer' -Class “__NAMESPACE” | Where-Object { $_.Name.StartsWith( 'ComputerManagement' ) }).Name

                    $cim = Get-CimInstance -Namespace "ROOT\Microsoft\SqlServer\$cmgmt" -Class FilestreamSettings | Where-Object {$_.InstanceName -eq $using:instanceName}
                    
                    Write-Verbose "The current access level of FILESTREAM is set to $($cim.AccessLevel) and the file share name is '$($cim.ShareName)'."
                    Write-Verbose "Expected access level of FILESTREAM is $using:fileStreamAccessLevel."
                    
                    if( $cim.AccessLevel -eq $using:fileStreamAccessLevel )
                    {
                        return $true  
                    }

                    return $false
                }
                SetScript = 
                {
                    # get installed SQL Server version
                    [string]$cmgmt = (Get-CimInstance -NameSpace 'ROOT\Microsoft\SQLServer' -Class “__NAMESPACE” | Where-Object { $_.Name.StartsWith( 'ComputerManagement' ) }).Name

                    $cmi = Get-CimInstance -Namespace "ROOT\Microsoft\SqlServer\$cmgmt" -Class FilestreamSettings | Where-Object {$_.InstanceName -eq $using:instanceName}

                    Write-Verbose "Set access level of FILESTREAM to $using:fileStreamAccessLevel."

                    $cmi.EnableFilestream( $using:fileStreamAccessLevel, $using:instanceName)
                    Get-Service -Name $using:instanceName | Restart-Service -Force
                     
                    Invoke-Sqlcmd "EXEC sp_configure filestream_access_level, $((2,$fileStreamAccessLevel | Measure-Object -Min).Minimum)"
                    Invoke-Sqlcmd "RECONFIGURE"
                }
                GetScript = { return 'NA' }   
                DependsOn = '[SqlSetup]sqlSetup'
            }
        }
    }
}
