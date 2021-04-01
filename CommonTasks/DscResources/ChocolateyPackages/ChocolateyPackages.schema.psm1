configuration ChocolateyPackages {
    param (
        [Parameter()]
        [hashtable]$Software,

        [Parameter()]
        [hashtable[]]$Sources,

        [Parameter()]
        [hashtable[]]$Packages,

        [Parameter()]
        [hashtable[]]$Features
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName Chocolatey

    $chocoSwExecName = 'Choco_Software'

    if( $Software -ne $null ) {

        if( [String]::IsNullOrWhiteSpace($Software.OfflineInstallZip) -eq $false )
        {
            # reduce footprint of serialized script parameter objects
            $swInstallationDirectory = $Software.InstallationDirectory
            $swOfflineInstallZip     = $Software.OfflineInstallZip
            
            Script OfflineInstallChocolatey
            {
                TestScript = {
                    # origin: https://github.com/chocolatey-community/Chocolatey/blob/master/Chocolatey/public/Test-ChocolateyInstall.ps1

                    try {
                        Write-Verbose "Loading machine Path Environment variable into session."
                        $envPath = [Environment]::GetEnvironmentVariable('Path','Machine')
                        [Environment]::SetEnvironmentVariable($envPath,'Process')

                        $installDir = $using:swInstallationDirectory

                        if ($installDir -and (Test-Path $installDir) ) {
                            $installDir = (Resolve-Path $installDir -ErrorAction Stop).Path
                        }

                        if ($chocoCmd = get-command choco.exe -CommandType Application -ErrorAction SilentlyContinue)
                        {
                            if (
                                !$installDir -or
                                $chocoCmd.Path -match [regex]::Escape($installDir)
                            )
                            {
                                Write-Verbose ('Chocolatey Software found in {0}' -f $chocoCmd.Path)
                                return $true
                            }
                            else
                            {
                                Write-Verbose (
                                    'Chocolatey Software not installed in {0}`n but in {1}' -f $installDir,$chocoCmd.Path
                                )
                                return $false
                            }
                        }
                        else {
                            Write-Verbose "Chocolatey Software not found."
                            return $false
                        }
                    }
                    catch {
                        Write-Verbose "Test for Chocolatey Software aborted with an exception.`n$_"
                        return $false
                    }
                }

                SetScript = {
                    # origin: https://github.com/chocolatey-community/Chocolatey/blob/master/Chocolatey/public/Install-ChocolateySoftware.ps1

                    if ($null -eq $env:TEMP) {
                        $env:TEMP = Join-Path $Env:SYSTEMDRIVE 'temp'
                    }

                    $tempDir = [io.path]::Combine($Env:TEMP,'chocolatey','chocInstall')
                    if (![System.IO.Directory]::Exists($tempDir)) {
                        $null = New-Item -path $tempDir -ItemType Directory
                    }

                    if( -not (Test-Path $using:swOfflineInstallZip) ) {
                        throw "Offline installation package '$($using:swOfflineInstallZip)' not found."
                    }

                    # copy the package with zip extension
                    $file = Resolve-Path $using:swOfflineInstallZip
                    $zipFile = [io.path]::Combine($Env:TEMP,'chocolatey','chocolatey.zip')

                    Write-Verbose "Copy install package '$file' to '$zipFile'..."

                    Copy-Item -Path $file -Destination $zipFile -Force

                    # unzip the package
                    Write-Verbose "Extracting $zipFile to $tempDir..."

                    if ($PSVersionTable.PSVersion.Major -ge 5) {
                        Expand-Archive -Path "$zipFile" -DestinationPath "$tempDir" -Force
                    }
                    else {
                        try {
                            $shellApplication = new-object -com shell.application
                            $zipPackage = $shellApplication.NameSpace($zipFile)
                            $destinationFolder = $shellApplication.NameSpace($tempDir)
                            $destinationFolder.CopyHere($zipPackage.Items(),0x10)
                        }
                        catch {
                            throw "Unable to unzip package using built-in compression. Error: `n $_"
                        }
                    }

                    # Call chocolatey install
                    Write-Verbose "Installing chocolatey on this machine."
                    $TempTools = [io.path]::combine($tempDir,'tools')
                    #   To be able to mock
                    $chocInstallPS1 = Join-Path $TempTools 'chocolateyInstall.ps1'

                    $chocoInstallDir = $using:swInstallationDirectory

                    if ($chocoInstallDir -ne $null -and $chocoInstallDir -ne '') {
                        Write-Verbose "Set Chocolatey installation directory to '$chocoInstallDir'"

                        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $chocoInstallDir, 'Machine')
                        [Environment]::SetEnvironmentVariable('ChocolateyInstall', $chocoInstallDir, 'Process')
                    }

                    Write-Verbose "EnvVar 'ChocolateyInstall': $([Environment]::GetEnvironmentVariable('ChocolateyInstall'))"

                    & $chocInstallPS1 | Write-Verbose

                    Write-Verbose 'Ensuring chocolatey commands are on the path.'
                    $chocoPath = [Environment]::GetEnvironmentVariable('ChocolateyInstall')
                    if ($chocoPath -eq $null -or $chocoPath -eq '') {
                        $chocoPath = "$env:ALLUSERSPROFILE\Chocolatey"
                    }

                    if (!(Test-Path ($chocoPath))) {
                        $chocoPath = "$env:SYSTEMDRIVE\ProgramData\Chocolatey"
                    }

                    $chocoExePath = Join-Path $chocoPath 'bin'

                    if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) {
                        $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
                    }

                    Write-Verbose 'Ensuring chocolatey.nupkg is in the lib folder'
                    $chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
                    $nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
                    $null = [System.IO.Directory]::CreateDirectory($chocoPkgDir)
                    Copy-Item "$file" "$nupkg" -Force -ErrorAction SilentlyContinue

                    if ($ChocoVersion = & "$chocoPath\choco.exe" -v) {
                        Write-Verbose "Installed Chocolatey Version: $ChocoVersion"
                    }

                    # reboot machine to activate the new environment variables for DSC
                    $global:DSCMachineStatus = 1
                }

                GetScript = { return @{result = 'N/A'} }
           }

           $Software.Remove('OfflineInstallZip')
           $Software.DependsOn = '[Script]OfflineInstallChocolatey'
        }

        (Get-DscSplattedResource -ResourceName ChocolateySoftware -ExecutionName $chocoSwExecName -Properties $Software -NoInvoke).Invoke($Software)
    }

    if( $Sources -ne $null ) {
        foreach ($s in $Sources) {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $s = @{}+$s

            $executionName = $s.Name -replace '\(|\)|\.| ', ''
            $executionName = "Choco_Source_$executionName"

            if (-not $s.ContainsKey('Ensure')) {
                $s.Ensure = 'Present'
            }

            if( $Software -ne $null ) {
                $s.DependsOn = "[ChocolateySoftware]$chocoSwExecName"
            }

            (Get-DscSplattedResource -ResourceName ChocolateySource -ExecutionName $executionName -Properties $s -NoInvoke).Invoke($s)
        }
    }

    if( $Packages -ne $null )
    {
        $clonedPackageList = [System.Collections.ArrayList]@()

        [uint16]$i = 0

        # set Rank attribute to allow a later ordering
        foreach ($p in $Packages)
        {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $p = @{}+$p
            # counter to keep original list order on equal rank values
            $i++

            if( [string]::IsNullOrWhiteSpace($p.Rank) )
            {
                # set default Rank to 1000
                $p.Rank = [UInt64](1000 * 100000 + $i)
            }
            else
            {
                $p.Rank = [UInt64]($p.Rank * 100000 + $i)
            }

            $clonedPackageList.Add( $p ) 
        }

        foreach ($p in ($clonedPackageList | Sort-Object {[UInt64]($_.Rank)}) )
        {
            $p.Remove( 'Rank' )

            $executionName = $p.Name -replace '\(|\)|\.| ', ''
            $executionName = "Chocolatey_$executionName"
            $p.ChocolateyOptions = [hashtable]$p.ChocolateyOptions

            if (-not $p.ContainsKey('Ensure')) {
                $p.Ensure = 'Present'
            }

            if( $Software -ne $null ) {
                $p.DependsOn = "[ChocolateySoftware]$chocoSwExecName"
            }

            [boolean]$forceReboot = $false
            if ($p.ContainsKey('ForceReboot')) {
                $forceReboot = $p.ForceReboot
                $p.Remove( 'ForceReboot' )
            }

            (Get-DscSplattedResource -ResourceName ChocolateyPackage -ExecutionName $executionName -Properties $p -NoInvoke).Invoke($p)

            if ($forceReboot -eq $true)
            {
                $rebootKeyName = 'HKLM:\SOFTWARE\DSC Community\CommonTasks\RebootRequests'
                $rebootVarName = "RebootAfter_$executionName"

                Script $rebootVarName
                {
                    TestScript = {
                        $val = Get-ItemProperty -Path $using:rebootKeyName -Name $using:rebootVarName -ErrorAction SilentlyContinue

                        if ($val -ne $null -and $val.$rebootVarName -gt 0) {
                            return $true
                        }
                        return $false
                    }
                    SetScript = {
                        if( -not (Test-Path -Path $using:rebootKeyName) ) {
                            New-Item -Path $using:rebootKeyName -Force
                        }
                        Set-ItemProperty -Path $rebootKeyName -Name $using:rebootVarName -value 1
                        $global:DSCMachineStatus = 1
                    }
                    GetScript = { return @{result = 'result'}}
                    DependsOn = "[ChocolateyPackage]$executionName"
                }
            }
        }
    }

    if( $Features -ne $null ) {
        foreach ($f in $Features) {
            # Remove Case Sensitivity of ordered Dictionary or Hashtables
            $f = @{}+$f

            $executionName = $f.Name -replace '\(|\)|\.| ', ''
            $executionName = "ChocolateyFeature_$executionName"
            if (-not $f.ContainsKey('Ensure')) {
                $f.Ensure = 'Present'
            }
            (Get-DscSplattedResource -ResourceName ChocolateyFeature -ExecutionName $executionName -Properties $f -NoInvoke).Invoke($f)
        }
    }
}
