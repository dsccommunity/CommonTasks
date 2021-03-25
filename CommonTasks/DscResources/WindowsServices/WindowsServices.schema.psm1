configuration WindowsServices {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Services
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    foreach ($service in $Services)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $service = @{}+$service

        $service.Ensure = 'Present'

        # set defaults if no state is specified
        if( [string]::IsNullOrWhiteSpace($service.State) )
        {
            # check for running service only if none or a compatible startup type is specified
            if( [string]::IsNullOrWhiteSpace($service.StartupType) -or ($service.StartupType -eq 'Automatic') )
            {
                $service.State = 'Running'
            }
            elseif( $service.StartupType -eq 'Disabled' )
            {
                $service.State = 'Stopped'
            }
            else
            {
                $service.State = 'Ignore'
            }
        }

        $executionName = "winsvc_$($Service.Name -replace '[-().:\s]', '_')"

        #how splatting of DSC resources works: https://gaelcolas.com/2017/11/05/pseudo-splatting-dsc-resources/
        (Get-DscSplattedResource -ResourceName xService -ExecutionName $executionName -Properties $service -NoInvoke).Invoke($service)
    }
}
