configuration XmlContent {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $XmlData
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName XmlContentDsc

    foreach ($xmlRecord in $XmlData)
    {
        if ($xmlRecord.Attributes -is [System.Collections.Specialized.OrderedDictionary])
        {
            $xmlRecord.Attributes = [hashtable]$xmlRecord.Attributes
        }
        (Get-DscSplattedResource -ResourceName XmlFileContentResource -ExecutionName ($xmlRecord.Path + '_' + $xmlRecord.XPath) -Properties $xmlRecord -NoInvoke).Invoke($xmlRecord)
    }
}
