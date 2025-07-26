Import-Module -Name datum
$here = $PSScriptRoot

$datum = New-DatumStructure -DefinitionFile $here\Unit\DSCResources\Assets\Datum.yml
$allNodes = Get-Content -Path $here\Unit\DSCResources\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

Write-Host 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
Initialize-DscResourceMetaInfo -ModulePath $here\..\output\RequiredModules\
Write-Host 'Done'

$global:configurationData = @{
    AllNodes = [array]$allNodes
    Datum    = $Datum
}

$dscResourceName = 'HyperV'

configuration "Config_$dscResourceName" {

    Import-DscResource -ModuleName CommonTasks -Name HyperV

    node "localhost_$dscResourceName" {

        $data = $configurationData.Datum.Config."$dscResourceName"
        if (-not $data)
        {
            $data = @{}
        }

        (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $dscResourceName -Properties $data -NoInvoke).Invoke($data)
    }
}

& "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $here -ErrorAction Stop
