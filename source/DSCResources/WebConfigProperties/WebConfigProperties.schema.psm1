configuration WebConfigProperties {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
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

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration

    foreach ($item in $Items)
    {
        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = "$($item.WebsitePath)_$($item.Filter)_$($item.PropertyName)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xWebConfigProperty -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
