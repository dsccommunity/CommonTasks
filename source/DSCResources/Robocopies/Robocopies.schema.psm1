Configuration Robocopies
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Items
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName xRobocopy

    foreach ($item in $Items)
    {
        $item = @{} + $item

        $executionName = "xRobocopy_$($item.Destination)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xRobocopy -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
