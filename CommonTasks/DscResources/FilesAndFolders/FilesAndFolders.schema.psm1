Configuration FilesAndFolders {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.2.0

    foreach ($item in $Items)
    {

        $shareName = $item.ShareName
        $item.Remove('ShareName')
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $resourceName = "$($item.DestinationPath -replace '\s|:|\\|\.')$((New-Guid).Guid)"
        (Get-DscSplattedResource -ResourceName File -ExecutionName $resourceName -Properties $item -NoInvoke).Invoke($item)

        if ($ShareName)
        {
            SmbShare $shareName
            {
                Name      = $ShareName
                Path      = $Item.DestinationPath
                DependsOn = "[File]$resourceName"
            }
        }
    }
}