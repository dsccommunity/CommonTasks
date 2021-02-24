configuration DhcpServerOptionDefinitions
{
    param
    (
        [hashtable[]]
        $ServerOptionDefinitions
    )

<#
    AddressFamily = [string]{ IPv4 }
    Name = [string]
    OptionId = [UInt32]
    Type = [string]{ BinaryData | Byte | Dword | DwordDword | EncapsulatedData | IPv4Address | String | Word }
    VendorClass = [string]
    [DependsOn = [string[]]]
    [Description = [string]]
    [Ensure = [string]{ Absent | Present }]
    [Multivalued = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
#>

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    foreach ($serverOptionDefinition in $ServerOptionDefinitions) {
        if (-not $serverOptionDefinition.ContainsKey('Ensure')) {
            $serverOptionDefinition.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($serverOption.OptionId)"
        (Get-DscSplattedResource -ResourceName xDhcpServerOptionDefinition -ExecutionName $executionName -Properties $serverOptionDefinition -NoInvoke).Invoke($serverOptionDefinition)
    }
}
