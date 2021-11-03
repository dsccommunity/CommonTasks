# see https://github.com/dsccommunity/AuditPolicyDsc
configuration AuditPolicies
{
    param
    (
        [Parameter()]
        [hashtable[]]
        $Options,

        [Parameter()]
        [hashtable[]]
        $Subcategories,

        [Parameter()]
        [hashtable[]]
        $Guids,

        [Parameter()]
        [String]
        $CsvPath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName AuditPolicyDsc

    if( $null -ne $Options )
    {
        foreach( $option in $Options )
        {
            $executionName = "auditPolOpt_" + ($option.Name -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName AuditPolicyOption -ExecutionName $executionName -Properties $option -NoInvoke).Invoke( $option )
        }
    }
    
    if( $null -ne $Subcategories )
    {
        foreach( $subcat in $Subcategories )
        {
            $executionName = "auditPolSubcat_" + ($subcat.Name -replace '\(|\)|\.|:| ', '') + "_" + ($subcat.AuditFlag -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName AuditPolicySubcategory -ExecutionName $executionName -Properties $subcat -NoInvoke).Invoke( $subcat )
        }
    }

    if( $null -ne $Guids )
    {
        foreach( $guid in $Guids )
        {
            $executionName = "auditPolGuid_" + ($guid.Name -replace '\(|\)|\.|:| ', '') + "_" + ($guid.AuditFlag -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName AuditPolicySubcategory -ExecutionName $executionName -Properties $guid -NoInvoke).Invoke( $guid )
        }
    }

    if( -not [String]::IsNullOrWhiteSpace($CsvPath) )
    {
        $auditPolicyCsv = @{
            CsvPath          = $CsvPath
            IsSingleInstance = 'Yes'
        }
        (Get-DscSplattedResource -ResourceName AuditPolicyCsv -ExecutionName "auditPolicyCsv" -Properties $auditPolicyCsv -NoInvoke).Invoke( $auditPolicyCsv )
    }
}
