configuration SqlConfigurations {
    param (
        [Parameter()]
        [String]$DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory)]
        [hashtable[]]$Options
    )

    <#
    InstanceName = [string]
    OptionName = [string]
    OptionValue = [Int32]
    [DependsOn = [string[]]]
    [PsDscRunAsCredential = [PSCredential]]
    [RestartService = [bool]]
    [RestartTimeout = [UInt32]]
    [ServerName = [string]]
    #>
    
    Import-DscResource -ModuleName SqlServerDsc

    foreach ($option in $Options) 
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $option = @{}+$option

        if( [string]::IsNullOrWhiteSpace($option.InstanceName)  )
        {
            $option.InstanceName = $DefaultInstanceName
        }

        $executionName = "$($option.InstanceName)_$($option.OptionName -replace ' ','')"
        (Get-DscSplattedResource -ResourceName SqlConfiguration -ExecutionName $executionName -Properties $option -NoInvoke).Invoke($option)
    }
}
