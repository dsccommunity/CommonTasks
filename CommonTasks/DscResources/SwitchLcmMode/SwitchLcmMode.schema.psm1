configuration SwitchLcmMode
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $SourceMetaMofDir,

        [Parameter()]
        [String]
        $TargetMetaMofDir,

        [Parameter()]
        [String]
        $ConfigurationName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $TaskName = 'SwitchLcmMode'

    Script 'switchLcmMode'
    {
        TestScript = {
            $lcm = Get-DscLocalConfigurationManager

            if( $lcm.RefreshMode -eq 'Pull' )
            {
                $scheduledTask = Get-ScheduledTask | Where-Object {$_.TaskName -like $using:TaskName}
                if( $null -ne $scheduledTask )
                {
                    Write-Host "Delete schedule task '$using:TaskName'."
                    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
                }

                return $true
            }

            Write-Verbose "Current LCM mode is '$($lcm.RefreshMode)', expected is 'Pull'"
            return $false
        }
        SetScript = {
            $cfgName = $using:ConfigurationName
            $targetDir = $using:TargetMetaMofDir

            if( [string]::IsNullOrWhiteSpace($cfgName) )
            {
                $cfgName = $env:ComputerName
            }

            if( [string]::IsNullOrWhiteSpace($targetDir) )
            {
                $targetDir = "$($env:TEMP)\DSC_Config"
            }

            $srcMetaMofPath = "$($using:SourceMetaMofDir)\$($cfgName).meta.mof"

            if( -not (Test-Path $srcMetaMofPath) )
            {
                throw "New MetaMOF file '$srcMetaMofPath' not found."
            }

            Write-Verbose "Creating target folder '$targetDir'..."
            New-Item -Path $targetDir -ItemType Directory -Force -ErrorAction SilentlyContinue
            
            Write-Verbose "Copy MetaMOF '$srcMetaMofPath' into target folder..."
            Copy-Item -Path $srcMetaMofPath -Destination $targetDir -Force -ErrorAction Stop

            $scheduledTask = Get-ScheduledTask | Where-Object {$_.TaskName -like $using:TaskName}
            if( $null -ne $scheduledTask )
            {
                Write-Host "Delete existing schedule task '$using:TaskName'."
                Unregister-ScheduledTask -TaskName $using:TaskName -Confirm:$false -ErrorAction SilentlyContinue
            }

            Write-Verbose "Create scheduled task '$using:TaskName' to activate new DSC configuration..."

            $scriptCode = @"
            Start-Transcript -Path "`$PSScriptRoot\`$(`$MyInvocation.MyCommand.Name).log" -Append

            try
            {
                `$lcm = Get-DscLocalConfigurationManager -ErrorAction Stop

                `$metaMofPath = `'$targetDir\$cfgName.meta.mof`'

                if( -not (Test-Path `$metaMofPath) )
                {
                    throw "ERROR: Missing LCM configuration file `'`$metaMofPath`'."
                }

                if( `$null -ne `$lcm -and `$lcm.RefreshMode -eq 'Push' )
                {
                    Stop-DscConfiguration -Force -ErrorAction SilentlyContinue

                    Remove-DscConfigurationDocument -Stage Pending -Force
                    Remove-DscConfigurationDocument -Stage Current -Force

                    Set-DscLocalConfigurationManager -Path `'$targetDir`' -ComputerName $cfgName -Force -Verbose

                    Update-DscConfiguration -Wait -Verbose
                }
            }
            catch
            {
                Write-Error "Switch to LCM Pull mode failed with error.`n$_"
            }
            finally
            {
                Stop-Transcript
            }
"@

            $scriptFilePath = "$targetDir\$using:TaskName.ps1"
            $scriptCode | Set-Content -Path $scriptFilePath -Encoding UTF8 -Force

            # skip recreation of existing scheduled task
            if( $null -eq (Get-ScheduledTask $using:TaskName -ErrorAction SilentlyContinue) )
            {
                $ta = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File $scriptFilePath"
                # Start at System Startup and repeat Task every 5 minutes for 12 hours
                $tt1 = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Minutes 6)
                $tt2 = New-ScheduledTaskTrigger -At (Get-Date).AddMinutes(10) -Once -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Hours 12)
                Register-ScheduledTask $using:TaskName -Action $ta -Trigger @($tt1, $tt2) -User 'System' -Force -ErrorAction Stop

                # Restart system to allow a well defined switch from Push to Pull mode
                $global:DSCMachineStatus = 1
            }
        }
        GetScript = { return @{result = 'N/A'}}
    }        
}
