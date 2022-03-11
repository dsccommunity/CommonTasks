Configuration VSTSAgents
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [hashtable[]] $Agents
    )

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
}
