configuration FileContents
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $IniSettingsFiles,

        [Parameter()]
        [hashtable[]]
        $KeyValuePairFiles,

        [Parameter()]
        [hashtable[]]
        $ReplaceTexts

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName FileContentDsc

    foreach ($iniSettingsFile in $IniSettingsFiles)
    {
        $executionName = '{0}_{1}_{2}' -f $iniSettingsFile.Path, $iniSettingsFile.Section, $iniSettingsFile.Key
        $executionName = $executionName -replace "[\s()\\:*-+/{}```"']", '_'

        (Get-DscSplattedResource -ResourceName IniSettingsFile -ExecutionName $executionName -Properties $iniSettingsFile -NoInvoke).Invoke($iniSettingsFile)
    }

    foreach ($keyValuePairFile in $KeyValuePairFiles)
    {
        $executionName = '{0}_{1}' -f $keyValuePairFile.Path, $keyValuePairFile.Name
        $executionName = $executionName -replace "[\s()\\:*-+/{}```"']", '_'

        (Get-DscSplattedResource -ResourceName KeyValuePairFile -ExecutionName $executionName -Properties $keyValuePairFile -NoInvoke).Invoke($keyValuePairFile)
    }

    foreach ($replaceText in $ReplaceTexts)
    {
        $executionName = '{0}_{1}' -f $replaceText.Path, $replaceText.Search
        $executionName = $executionName -replace "[\s()\\:*-+/{}```"']", '_'

        (Get-DscSplattedResource -ResourceName ReplaceText -ExecutionName $executionName -Properties $replaceText -NoInvoke).Invoke($replaceText)
    }

}
