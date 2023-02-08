Configuration PowershellExecutionPolicies
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Policies
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName ComputerManagementDsc

    foreach ($policy in $Policies)
    {
        $policy = @{} + $policy

        $executionName = "PowershellExecutionPolicy_$($policy.ExecutionPolicyScope)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName PowershellExecutionPolicy -ExecutionName $executionName -Properties $policy -NoInvoke).Invoke($policy)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
