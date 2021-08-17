configuration FilesAndFolders
{
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName FileSystemDsc

    foreach ($item in $Items)
    {
        $permissions = $null

        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $item = @{}+$item

        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        if( $item.ContainsKey('Permissions') )
        {
            $permissions = $item.Permissions
            $item.Remove('Permissions')
        }

        $executionName = "file_$($item.DestinationPath -replace '(:|\\|/|\s)', '_')"
        (Get-DscSplattedResource -ResourceName File -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)

        if( $null -ne $permissions )
        {
            foreach ($perm in $permissions)
            {         
                # Remove Case Sensitivity of ordered Dictionary or Hashtables
                $perm = @{}+$perm

                $perm.Path      = $item.DestinationPath
                $perm.DependsOn = "[File]$executionName"

                if (-not $perm.ContainsKey('Ensure'))
                {
                    $perm.Ensure = 'Present'
                }

                $permExecName = "$($executionName)__$($perm.Identity -replace '(:|\\|/|\s)', '_')"
                (Get-DscSplattedResource -ResourceName FileSystemAccessRule -ExecutionName $permExecName -Properties $perm -NoInvoke).Invoke($perm)
            }
        }
    }
}
