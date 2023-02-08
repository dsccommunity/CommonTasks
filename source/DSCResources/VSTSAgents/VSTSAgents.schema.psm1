Configuration VSTSAgents
{
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Agents
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName VSTSAgent

    foreach ($agent in $Agents)
    {
        $agent = @{} + $agent

        if (-not $agent.ContainsKey("Ensure"))
        {
            $agent.Ensure = "Present"
        }

        $executionName = "xVSTSAgent_$($agent.Name)" -replace '[\s(){}/\\:-]', '_'
        (Get-DscSplattedResource -ResourceName xVSTSAgent -ExecutionName $executionName -Properties $agent -NoInvoke).Invoke($agent)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
