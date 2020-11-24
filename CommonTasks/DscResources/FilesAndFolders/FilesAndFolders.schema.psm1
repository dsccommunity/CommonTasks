configuration FilesAndFolders {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($item in $Items) {
        
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = $item.DestinationPath -replace ':|\s', ''
        (Get-DscSplattedResource -ResourceName File -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
