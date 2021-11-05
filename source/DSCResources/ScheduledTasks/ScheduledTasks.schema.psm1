configuration ScheduledTasks
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Tasks
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    foreach( $task in $Tasks )
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $task = @{}+$task

        if( $null -ne $task.ExecuteAsCredential )
        {
            $task.ExecuteAsCredential = [PSCredential]$task.ExecuteAsCredential
            #$task.Remove( 'ExecuteAsCredential' )
        }

        $executionName = "task_$($task.TaskName -replace '[().:\s]', '')"

        (Get-DscSplattedResource -ResourceName ScheduledTask -ExecutionName $executionName -Properties $task -NoInvoke).Invoke($task)
    }
}
