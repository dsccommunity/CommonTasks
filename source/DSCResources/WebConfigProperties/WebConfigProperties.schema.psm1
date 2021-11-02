configuration WebConfigProperties {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Items
    )

    <#
    Filter = [string]
    PropertyName = [string]
    WebsitePath = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    [Value = [string]]
    #>
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    foreach ($item in $Items) {
        
        if (-not $item.ContainsKey('Ensure')) {
            $item.Ensure = 'Present'
        }

        $executionName = $item.PropertyName
        (Get-DscSplattedResource -ResourceName xWebConfigProperty -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
