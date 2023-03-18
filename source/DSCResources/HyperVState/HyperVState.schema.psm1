# see https://github.com/dsccommunity/HyperVDsc
configuration HyperVState
{
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable[]]
        $VMMachines
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName HyperVDsc


    foreach ($vmmachine in $VMMachines)
    {
        $vmName               = $vmmachine.Name
        $vmState              = $vmmachine.State
        $automaticStartAction = $vmmachine.AutomaticStartAction
        $automaticStartDelay  = $vmmachine.AutomaticStartDelay
        $automaticStopAction  = $vmmachine.AutomaticStopAction

        $execName = "HyperVState_$vmName" -replace '[\s(){}/\\:-]', '_'

        Script $execName
        {
            TestScript = {
                [boolean]$status = $true
                $vmProp = Get-VM -VMName $using:vmName | Select-Object State, AutomaticStartAction, AutomaticStartDelay, AutomaticStopAction

                if ($null -ne $vmProp)
                {
                    Write-Verbose "VM settings of '$using:vmName':`n$vmProp"

                    if (($null -ne $using:checkpointType -and $vmProp.State -ne $using:vmState) -or
                        ($null -ne $using:automaticStartAction -and $vmProp.AutomaticStartAction -ne $using:automaticStartAction) -or
                        ($null -ne $using:automaticStartDelay -and $vmProp.AutomaticStartDelay -ne $using:automaticStartDelay) -or
                        ($null -ne $using:automaticStopAction -and $vmProp.AutomaticStopAction -ne $using:automaticStopAction))
                    {
                        $status = $false
                    }
                }
                else
                {
                    Write-Verbose 'VM settings not available.'
                    $status = $false
                }
                return $status
            }
            SetScript  = {
                $vmProps = @{
                    VMName = $using:vmName
                }

                if ($null -ne $using:automaticStartAction)
                {
                    $vmProps.AutomaticStartAction = $using:automaticStartAction
                }
                if ($null -ne $using:automaticStartDelay)
                {
                    $vmProps.AutomaticStartDelay = $using:automaticStartDelay
                }
                if ($null -ne $using:automaticStopAction)
                {
                    $vmProps.AutomaticStopAction = $using:automaticStopAction
                }

                Set-VM @vmProps

                if ($null -ne $using:vmState)
                {
                    if ($using:vmState -eq 'Running')
                    {
                        Start-VM -Name $using:vmName
                    }
                    elseif ($using:vmState -eq 'Off')
                    {
                        Stop-VM -Name $using:vmName
                    }
                    elseif ($using:vmState -eq 'Paused')
                    {
                        Suspend-VM -Name $using:vmName
                    }
                }
            }
            GetScript  = { return `
                @{
                    result = 'N/A'
                }
            }
        }
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
