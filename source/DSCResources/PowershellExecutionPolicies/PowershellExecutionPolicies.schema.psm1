Configuration PowershellExecutionPolicies
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Policies
    )

    Import-DscResource -ModuleName ComputerManagementDsc

    foreach ($policy in $Policies)
    {
        $policy = @{} + $policy

        $executionName = "PowershellExecutionPolicy_$($policy.ExecutionPolicyScope)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName PowershellExecutionPolicy -ExecutionName $executionName -Properties $policy -NoInvoke).Invoke($policy)
    }
}
