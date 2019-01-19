Configuration XmlContent {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$XmlData
    )
    
    Import-DscResource -ModuleName XmlContentDsc

    foreach ($xmlRecord in $XmlData) {
        (Get-DscSplattedResource -ResourceName XmlFileContentResource -ExecutionName $xmlRecord.Path -Properties $xmlRecord -NoInvoke).Invoke($xmlRecord)
    }
}