configuration DnsSuffixes
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Suffixes
    )

    Import-DscResource -ModuleName NetworkingDsc -Name DnsConnectionSuffix

    foreach ($suffix in $Suffixes)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $suffix = @{} + $suffix

        if (-not $suffix.ContainsKey('Ensure'))
        {
            $suffix.Ensure = 'Present'
        }

        $executionName = "dnssuffix_$($suffix.InterfaceAlias)_$($suffix.ConnectionSpecificSuffix)" -replace '[()-.:\s]', '_'

        (Get-DscSplattedResource -ResourceName DnsConnectionSuffix -ExecutionName $executionName -Properties $suffix -NoInvoke).Invoke($suffix)
    }
}
