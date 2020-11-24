configuration WindowsEventLogs {
    Param (
        [Parameter(Mandatory)]
        [hashtable[]]$Logs
    )
    
    Import-DscResource -ModuleName ComputerManagementDsc
   
    foreach ($log in $Logs) {
        
        $executionName = "$($log.LogName)"
        (Get-DscSplattedResource -ResourceName WindowsEventLog -ExecutionName $executionName -Properties $log -NoInvoke).Invoke($log)

    }

}
