configuration WindowsServices {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Services
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    foreach ($service in $Services)
    {
        $service.Ensure = 'Present'
        if (-not $service.State)
        {
            $service.State = 'Running'
        }

        $executionName = "winsvc_$($Service.Name -replace '[-().:\s]', '_')"

        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        (Get-DscSplattedResource -ResourceName Service -ExecutionName $executionName -Properties $service -NoInvoke).Invoke($service)
    }
}
