configuration RemoteDesktopCollections
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Collections
    )

    <#
        @{
            CollectionName
            SessionHost
            CollectionDescription
            ConnectionBroker
            Settings = @{
                ActiveSessionLimitMin
                AuthenticateUsingNLA
                AutomaticReconnectionEnabled
                BrokenConnectionAction
                ClientDeviceRedirectionOptions
                ClientPrinterAsDefault
                ClientPrinterRedirected
                CollectionDescription
                CustomRdpProperty
                DisconnectedSessionLimitMin
                EncryptionLevel
                IdleSessionLimitMin
                MaxRedirectedMonitors
                RDEasyPrintDriverEnabled
                SecurityLayer
                TemporaryFoldersDeletedOnExit
                UserGroup
                DiskPath
                EnableUserProfileDisk
                MaxUserProfileDiskSizeGB
                IncludeFolderPath
                ExcludeFolderPath
                IncludeFilePath
                ExcludeFilePath
            }
        }
    #>
    Import-DscResource -ModuleName RemoteDesktopServicesDsc

    foreach ($collection in $Collections)
    {
        $executionName = "rdsc_$($collection.CollectionName -replace '[().:\s]', '')"
        if ($collection.Settings)
        {
            $collectionSettings = @{} + $collection.Settings
            if (-not $collectionSettings.Contains('ConnectionBroker'))
            {
                $collectionSettings['ConnectionBroker'] = $collection.ConnectionBroker
            }
            if (-not $collectionSettings.Contains('CollectionName'))
            {
                $collectionSettings['CollectionName'] = $collection.CollectionName
            }

            $collectionSettings['DependsOn'] = "[RDSessionCollection]$executionName"
            $collection.Remove('Settings')
        }

        (Get-DscSplattedResource -ResourceName RDSessionCollection -ExecutionName $executionName -Properties $collection -NoInvoke).Invoke($collection)

        if ($null -ne $collectionSettings)
        {
            $executionName = "rdsc_settings_$($collection.CollectionName -replace '[().:\s]', '')"
            (Get-DscSplattedResource -ResourceName RDSessionCollectionConfiguration -ExecutionName $executionName -Properties $collectionSettings -NoInvoke).Invoke($collectionSettings)
        }
    }
}
