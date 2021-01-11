configuration RegistryPolicies {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Values,

        [Parameter()]
        [int]$GpUpdateInterval = 20
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName GPRegistryPolicyDsc

    [string]$executionName = $null
    [int]$refreshCounter = 0

    # Set default gpupdate interval if necessary
    if( ($null -eq $GpUpdateInterval) -or ($GpUpdateInterval -le 0) ) {
        $GpUpdateInterval = 20
    }

    foreach ($value in $values) {
        
        if (-not $value.ContainsKey('Ensure')) {
            $value.Ensure = 'Present'
        }
        if (-not $value.ContainsKey('TargetType')) {
            $value.TargetType = 'ComputerConfiguration'
        }
        if ([String]::IsNullOrEmpty($value.ValueName)) {
            $value.ValueName = ''
        }
        if ([String]::IsNullOrEmpty($value.ValueData) -and ($value.Ensure -eq 'Present')) {
            $value.ValueData = ''
        }
        if( [string]::IsNullOrEmpty($executionName) -eq $false )
        {
            # set dependency to previous policy
            $value.DependsOn = "[RegistryPolicyFile]$executionName"
        }
        if ($value.ContainsKey('Force')) {
            if( $value.Force -eq 'True') {
                # set counter threshold so that RefreshRegistryPolicy will be generated after this value
                $refreshCounter = $GpUpdateInterval
            }
            $value.Remove('Force')
        }
        $executionName = "$($value.Key)\$($value.ValueName)" -replace "[\s\\:*-+/{}```"']", '_'
        (Get-DscSplattedResource -ResourceName RegistryPolicyFile -ExecutionName $executionName -Properties $value -NoInvoke).Invoke($value)

        $refreshCounter += 1

        if( $refreshCounter -ge $GpUpdateInterval )
        {
            $refreshCounter = 0

            # update policies after set of 10 policy values
            RefreshRegistryPolicy "$($executionName)_Refresh"
            {
                IsSingleInstance = 'Yes'
                DependsOn        = "[RegistryPolicyFile]$executionName"
            }

            # clear gpupdate dependency
            $executionName = $null
        }
    }

    # update policies after set of the last policy value
    if( $refreshCounter -gt 0 )
    {
        RefreshRegistryPolicy 'RefreshLastRegistryPolicies'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = "[RegistryPolicyFile]$executionName"
        }
    }
}
