# see https://github.com/dsccommunity/SecurityPolicyDsc
configuration SecurityPolicies
{
    param
    (
        [Parameter()]
        [Hashtable[]]
        $AccountPolicies,

        [Parameter()]
        [Hashtable[]]
        $SecurityOptions,

        [Parameter()]
        [Hashtable[]]
        $UserRightsAssignments,

        [Parameter()]
        [String]
        $SecurityTemplatePath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SecurityPolicyDsc

    if( $null -ne $AccountPolicies )
    {
        foreach( $policy in $AccountPolicies )
        {
            $executionName = "secPolAcc_" + ($policy.Name -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName AccountPolicy -ExecutionName $executionName -Properties $policy -NoInvoke).Invoke( $policy )
        }
    }
    
    if( $null -ne $SecurityOptions )
    {
        foreach( $option in $SecurityOptions )
        {
            $executionName = "secPolOpt_" + ($option.Name -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName SecurityOption -ExecutionName $executionName -Properties $option -NoInvoke).Invoke( $option )
        }
    }

    if( $null -ne $UserRightsAssignments )
    {
        foreach( $assign in $UserRightsAssignments )
        {
            if( -not $assign.ContainsKey( 'Ensure' ) )
            {
                $assign.Ensure = 'Present'
            }

            if ($null -eq $assign.Identity)
            {
                throw "UserRightsAssignment: Attribute 'Identity' of policy '$($assign.Policy)' is missing and must have a value (specify an empty value with '')."
            }

            $executionName = "secPolUsr_" + ($assign.Policy -replace '\(|\)|\.|:| ', '')
            (Get-DscSplattedResource -ResourceName UserRightsAssignment -ExecutionName $executionName -Properties $assign -NoInvoke).Invoke( $assign )
        }
    }

    if( -not [String]::IsNullOrWhiteSpace($SecurityTemplatePath) )
    {
        $securityTemplate = @{
            Path             = $SecurityTemplatePath
            IsSingleInstance = 'Yes'
        }
        (Get-DscSplattedResource -ResourceName SecurityTemplate -ExecutionName "secTemplate" -Properties $securityTemplate -NoInvoke).Invoke( $securityTemplate )
    }
}
