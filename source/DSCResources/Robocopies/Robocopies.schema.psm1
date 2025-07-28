configuration Robocopies
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Items
    )

    Import-DscResource -ModuleName xRobocopy

    foreach ($item in $Items)
    {
        $item = @{} + $item

        $executionName = "xRobocopy_$($item.Destination)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xRobocopy -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
