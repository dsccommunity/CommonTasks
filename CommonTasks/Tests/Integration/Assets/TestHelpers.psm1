function Init
{
    $datum = New-DatumStructure -DefinitionFile $PSScriptRoot\Datum.yml
    $allNodes = Get-Content -Path $PSScriptRoot\AllNodes.yml -Raw | ConvertFrom-Yaml
    #$configData = $datum.Config.ToHashTable() 
    #$configData.AllNodes = [hashtable[]]$configData.AllNodes
    
    $moduleName = $env:BHProjectName
    Remove-Module -Name $env:BHProjectName -ErrorAction SilentlyContinue -Force
    Import-Module -Name $env:BHProjectName -ErrorAction Stop
    Import-Module -Name datum

    $global:configurationData = @{
        AllNodes = [array]$allNodes
        Datum = $Datum
    }
}
