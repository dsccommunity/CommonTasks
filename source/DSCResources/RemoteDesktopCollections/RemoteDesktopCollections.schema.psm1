configuration RemoteDesktopCollections
{
    param
    (
        [Parameter(Mandatory)]
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
    Import-DscResource -ModuleName xRemoteDesktopSessionHost

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

            $collectionSettings['DependsOn'] = "[xRDSessionCollection]$executionName"
            $collection.Remove('Settings')
        }

        (Get-DscSplattedResource -ResourceName xRDSessionCollection -ExecutionName $executionName -Properties $collection -NoInvoke).Invoke($collection)

        if ($null -ne $collectionSettings)
        {
            $executionName = "rdsc_settings_$($collection.CollectionName -replace '[().:\s]', '')"
            (Get-DscSplattedResource -ResourceName xRDSessionCollectionConfiguration -ExecutionName $executionName -Properties $collectionSettings -NoInvoke).Invoke($collectionSettings)
        }
    }
}
