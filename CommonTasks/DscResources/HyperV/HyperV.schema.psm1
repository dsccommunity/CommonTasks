# see https://github.com/dsccommunity/xHyper-V
configuration HyperV
{
    param
    (
        [Parameter()]
        [ValidateSet('Server', 'Client')]
        $HostOS = 'Server',

        [Parameter()]
        [hashtable[]]
        $VMSwitches,

        [Parameter()]
        [hashtable[]]
        $VMMachines
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName 'xHyper-V'

    [string]$dependsOnHostOS = $null

    if( $HostOS -eq 'Server' )
    {
        WindowsFeature 'Hyper-V-WinSrv'
        {
            Name   = 'Hyper-V'
            Ensure = 'Present'
        }
    
        WindowsFeature 'Hyper-V-Powershell-WinSrv'
        {
            Name        = 'Hyper-V-Powershell'
            Ensure      = 'Present'
            DependsOn   = '[WindowsFeature]Hyper-V-WinSrv'
        }

        $dependsOnHostOS = '[WindowsFeature]Hyper-V-Powershell-WinSrv'
    }
    elseif( $HostOS -eq 'Client' )
    {
        WindowsOptionalFeature 'Hyper-V-Win10'
        {
            Name                 = 'Microsoft-Hyper-V-All'
            NoWindowsUpdateCheck = $true
            RemoveFilesOnDisable = $true
            Ensure               = 'Enable'
        }

        $dependsOnHostOS = '[WindowsOptionalFeature]Hyper-V-Win10'
    }

    #######################################################################
    #region Virtual switches
    if( $null -ne $VMSwitches )
    {
        $natSwitch = ''

        foreach( $vmswitch in $VMSwitches )
        {
            # Remove case sensitivity of ordered Dictionary or Hashtables
            $vmswitch = @{} + $vmswitch

            $netName         = $vmswitch.Name
            $netAddressSpace = $vmswitch.AddressSpace
            $netGateway      = $vmswitch.Gateway

            $vmSwitch.Remove('AddressSpace')
            $vmSwitch.Remove('Gateway')

            if( $vmswitch.Type -eq 'NAT' )
            {
                if( -not [string]::IsNullOrWhiteSpace($natSwitch) )
                {
                    throw "ERROR: Only one NAT switch is supported."
                }

                if( [string]::IsNullOrWhiteSpace($netAddressSpace) -or [string]::IsNullOrWhiteSpace($netGateway) )
                {
                    throw "ERROR: A NAT switch requires the 'AddressSpace' and 'Gateway' attributes."
                }

                $natSwitch     = $vmswitch.Name
                $vmswitch.Type = 'Internal'
             }

            $vmswitch.DependsOn = $dependsOnHostOS
            $executionName = $vmswitch.Name -replace '[().:\s]', '_'
            (Get-DscSplattedResource -ResourceName xVMSwitch -ExecutionName "vmswitch_$executionName" -Properties $vmswitch -NoInvoke).Invoke( $vmswitch )

            # enable Net Adressspace and NAT switch
            if( -not [string]::IsNullOrWhiteSpace($netAddressSpace) -or -not [string]::IsNullOrWhiteSpace($netGateway) )
            {
                $prefixSelect = $netAddressSpace | Select-String '\d+\.\d+\.\d+\.\d+/(\d+)'

                if( $null -eq $prefixSelect )
                {
                    throw "ERROR: Invalid format of attribute 'AddressSpace'."
                }

                if( -not ($netGateway -match '\d+\.\d+\.\d+\.\d+') )
                {
                    throw "ERROR: Invalid format of attribute 'Gateway'."
                }

                $netPrefixLength = $prefixSelect.Matches.Groups[1].Value

                Script "vmnet_$executionName"
                {
                    TestScript = 
                    {
                        [boolean]$result = $true
                        $netAdapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $using:netName }                    
                        $netIpAddr  = Get-NetIPAddress -IPAddress $using:netGateway -ErrorAction SilentlyContinue
                        $netNat     = Get-NetNat -Name $using:netName -ErrorAction SilentlyContinue

                        if( $null -eq $netAdapter )
                        {
                            $result = $false
                            Write-Verbose "NetAdapter containing switch name '$using:netName' not found."
                        }

                        if( $null -eq $netIpAddr -or
                            $netIpAddr.InterfaceIndex -ne $netAdapter.InterfaceIndex -or
                            $netIpAddr.PrefixLength -ne $using:netPrefixLength )
                        {
                            $result = $false
                            Write-Verbose "IP Address of gateway '$using:netGateway' not found or has not the expected configuration."
                        }

                        # check NAT switch
                        if( $using:netName -eq $using:natSwitch -and
                            ($null -eq $netNat -or
                             $netNat.InternalIPInterfaceAddressPrefix -ne $using:netAddressSpace) )
                        {
                            $result = $false
                            Write-Verbose "NetNAT '$using:netName' not found or has not the expected configuration."
                        }

                        $result
                        return $result
                    }
                    SetScript = 
                    {
                        $netAdapter = Get-NetAdapter | Where-Object { $_.Name -match $using:netName }                    

                        if( $null -eq $netAdapter )
                        {
                            throw "ERROR: NetAdapter containing switch name '$using:netName' not found."
                        }

                        # remove existing configuration
                        Remove-NetIPAddress -IPAddress $using:netGateway -Confirm:$false -ErrorAction SilentlyContinue

                        Write-Verbose "Create gateway IP Address '$using:netGateway'..."
                        New-NetIPAddress -IPAddress $using:netGateway -PrefixLength $using:netPrefixLength -InterfaceIndex $netAdapter.InterfaceIndex

                        if( $using:netName -eq $using:natSwitch )
                        {
                            Remove-NetNat $using:netName -Confirm:$false -ErrorAction SilentlyContinue

                            Write-Verbose "Create NetNat '$using:netName'..."
                            New-NetNat -Name $using:netName -InternalIPInterfaceAddressPrefix $using:netAddressSpace
                        }
                    }
                    GetScript = { return @{result = 'N/A' } }
                    DependsOn = "[xVMSwitch]vmswitch_$executionName"
                }
            }
        }
    }
    #endregion

    #######################################################################
    #region Virtual machines
    if( $null -ne $VMMachines )
    {
        foreach( $vmmachine in $VMMachines )
        {
            $vmName  = $vmmachine.Name

            # VM state will be handled as last step
            $vmState = $vmmachine.State
            $vmmachine.Remove( 'State' )

            $strVMDepend = "[xVMHyperV]$vmName"
            $strVHDPath  = "$($vmmachine.Path)\$vmName\Disks"
            $iMemorySize = ($vmmachine.StartupMemory / 1MB) * 1MB

            # save the additional disk and drives definitions
            $arrDisks  = @()
            $arrDrives = @()
            if( $vmmachine.Disks -is [System.Array] )
            {
                for( $i = 1; $i -lt $vmmachine.Disks.Count; ++$i )
                {
                    $arrDisks += $vmmachine.Disks[$i]
                }
            }
            foreach( $drive in $vmmachine.Drives )
            {
                $arrDrives += $drive
            }

            # create the OS disk
            $disk = $vmmachine.Disks[0]
            if( $disk.Path.Length -lt 1 ) { $disk.Path = $strVHDPath }
            $strVHDName = "$($vmName)_$($disk.Name).vhdx"
            $strVHDFile = "$($disk.Path)\$strVHDName"
            $folderVHD  = "$($vmName)_DiskPath_$($disk.Name)"
            $strVHD     = "$($vmName)_Disk_$($disk.Name)"
            File $folderVHD
            {
                Ensure          = 'Present'
                Type            = 'Directory'
                DestinationPath = $disk.Path
                DependsOn       = $dependsOnHostOS
            }

            if( $disk.Contains( 'CopyFrom' ) )
            {
                $strVHDDepend = "[FILE]$strVHD"
                File $strVHD
                {
                    Ensure          = 'Present'
                    Type            = 'File'
                    SourcePath      = $disk.CopyFrom
                    DestinationPath = $strVHDFile
                    DependsOn       = "[File]$folderVHD"
                }
            }
            else
            {
                $iDiskSize    = ($disk.Size / 1GB) * 1GB
                $strVHDDepend = "[xVHD]$strVHD"
                xVHD $strVHD
                {
                    Name             = $strVHDName
                    Path             = $strVHDPath
                    MaximumSizeBytes = $iDiskSize
                    Generation       = 'Vhdx'
                    Type             = 'Dynamic'
                    DependsOn        = "[File]$folderVHD"
                }
            }

            # copy files before VM starts at first time
            if( $null -ne $disk.CopyOnce )
            {
                [int]$i = 0

                foreach( $copyStep in $disk.CopyOnce )
                {       
                    $i++
                    $scriptCopyOnce = "$($vmName)_Disk_$($disk.Name)_CopyOnce_$i"
                    $sources        = @() + $copyStep.Sources
                    $targetDir      = $copyStep.Destination
                    $excludes       = @() + $copyStep.Excludes
                    $prepareScripts = @() + $copyStep.PrepareScripts

                    if( $sources.Count -eq 0 -or [string]::IsNullOrWhiteSpace($sources[0]) )
                    {
                        throw "ERROR: Missing CopyOnce sources at disk '$($disk.Name)' of VM '$vmName'."
                    }
                    if( [string]::IsNullOrWhiteSpace($copyStep.Destination) )   
                    {
                        throw "ERROR: Missing CopyOnce destination at disk '$($disk.Name)' of VM '$vmName'."
                    }

                    Script $scriptCopyOnce
                    {
                        TestScript = 
                        {
                            # run only before creation of VM
                            if( $null -eq (Get-VM -Name $using:vmName -ErrorAction SilentlyContinue) )
                            {
                                Write-Verbose "VM '$using:vmName' not found. Performing CopyOnce action is possible."
                                return $false
                            }

                            Write-Verbose "The destination VM '$using:vmName' was found and no action is required."
                            return $true
                        }
                        SetScript = 
                        {
                            # reset readonly flags of VHDX file
                            Write-Verbose "Reset readonly file attribute of VHDX '$using:strVHDFile'..."  
                            Set-ItemProperty -Path $using:strVHDFile -Name IsReadOnly -Value $false -ErrorAction Stop

                            Write-Verbose "Mounting VHDX '$using:strVHDFile' on host computer '$env:COMPUTERNAME'..."  
                            $mountedDisk = Mount-VHD -Path $using:strVHDFile -Passthru -ErrorAction Stop
                            try
                            {
                                # execute prepare scripts
                                foreach( $script in $using:prepareScripts )
                                {
                                    Write-Verbose "Executing scriptblock: $script"  
                                    $exec = [ScriptBlock]::Create($script)
                                    Invoke-Command -ScriptBlock $exec -ErrorAction Stop
                                }

                                [String]$driveLetter = ($mountedDisk | Get-Disk | Get-Partition | Where-Object {$_.Type -eq "Basic"} | Select-Object -ExpandProperty DriveLetter) + ":"
                                $driveLetter = $driveLetter -replace '\s',''
                                Write-Verbose "VHDX '$using:strVHDFile' mounted as drive '$driveLetter'"

                                [String]$targetPath = "$driveLetter\$using:targetDir"
                                
                                Start-Sleep -Seconds 2  #Optional
                                Get-PSDrive | Out-Null  #refresh PsDrive, Optional

                                Write-Verbose "Copy files from host source directories $($using:sources -join ', ') to mounted VHDX '$targetPath'..."  
                                New-Item -Path $targetPath -ItemType Directory -Force
                                Copy-Item -Path $using:sources -Destination $targetPath -Exclude $using:excludes -Recurse -Force -Verbose -ErrorAction Stop                            
                            }
                            finally
                            {
                                Start-Sleep -Seconds 2 #Optional
                                Dismount-VHD $mountedDisk.Path
                            }
                        }
                        GetScript = { return @{result = 'N/A' } }
                        DependsOn = $strVHDDepend
                    }
    
                    $strVHDDepend = "[Script]$scriptCopyOnce"
                }
            }
            
            # set computername in unattended.xml
            $scriptSetComputerName = "$($vmName)_Disk_$($disk.Name)_SetComputerName"

            Script $scriptSetComputerName
            {
                TestScript = {
                    # run only before creation of VM
                    if( $null -eq (Get-VM -Name $using:vmName -ErrorAction SilentlyContinue) )
                    {
                        Write-Verbose "The destination object was found and no action is required."
                        return $false
                    }                    

                    Write-Verbose "VM '$using:vmName' not found. Performing SetComputerName action is possible."
                    return $true
                }
                SetScript = {
                    # reset readonly flags of VHDX file
                    Write-Verbose "Reset readonly file attribute of VHDX '$using:strVHDFile'..."  
                    Set-ItemProperty -Path $using:strVHDFile -Name IsReadOnly -Value $false -ErrorAction Stop

                    Write-Verbose "Mounting VHDX '$using:strVHDFile' on host computer '$env:COMPUTERNAME'..."  
                    $mountedDisk = Mount-VHD -Path $using:strVHDFile -Passthru -ErrorAction Stop
                    try
                    {
                        [String]$driveLetter = ($mountedDisk | Get-Disk | Get-Partition | Where-Object {$_.Type -eq "Basic"} | Select-Object -ExpandProperty DriveLetter) + ":"
                        $driveLetter = $driveLetter -replace '\s',''
                        Write-Verbose "VHDX '$using:strVHDFile' mounted as drive '$driveLetter'"
                        
                        Start-Sleep -Seconds 2  #Optional
                        Get-PSDrive | Out-Null  #refresh PsDrive, Optional

                        # path unattend.xml on several search paths
                        $unattendXmlPathList = @( "$driveLetter\unattend.xml", "$driveLetter\Windows\Panther\unattend.xml" )

                        foreach( $unattendXmlPath in $unattendXmlPathList )
                        {
                            if( Test-Path -Path $unattendXmlPath )
                            {
                                Write-Verbose "Set computername in '$unattendXmlPath' to '$using:vmName' on mounted VHDX '$using:strVHDFile'."  

                                [xml]$unattendXml = Get-Content -Path $unattendXmlPath

                                $ns = New-Object System.Xml.XmlNamespaceManager($unattendXml.NameTable)
                                $ns.AddNamespace("ns","urn:schemas-microsoft-com:unattend")

                                # set computername
                                $computerNameXml = $unattendXml.SelectSingleNode('//ns:component[@name="Microsoft-Windows-Shell-Setup"]/ns:ComputerName', $ns)
                                $computerNameXml.InnerText = $using:vmName

                                # reset readonly flags of target file
                                Set-ItemProperty -Path $unattendXmlPath -Name IsReadOnly -Value $false
                                
                                $unattendXml.Save( $unattendXmlPath )
                            }
                            else
                            {
                                Write-Verbose "File '$unattendXmlPath' not found on mounted VHDX '$using:strVHDFile'. Skipping set of computername."  
                            }
                        }
                    }
                    finally
                    {
                        Start-Sleep -Seconds 2 #Optional
                        Dismount-VHD $mountedDisk.Path
                    }
                }
                GetScript = { return @{result = 'N/A' } }
                DependsOn = $strVHDDepend
            }

            $strVHDDepend = "[Script]$scriptSetComputerName"

            # save specific network adapter definition
            $networkAdapters = $vmmachine.NetworkAdapters

            # save additional settings
            $checkpointType               = $vmmachine.CheckpointType
            $automaticCheckpointsEnabled = $vmmachine.AutomaticCheckpointsEnabled
            $automaticStartAction         = $vmmachine.AutomaticStartAction
            $automaticStartDelay           = $vmmachine.AutomaticStartDelay
            $automaticStopAction          = $vmmachine.AutomaticStopAction

            # save security settings
            $tpmEnabled = $vmmachine.TpmEnabled

            # remove all additional settings
            $vmmachine.Remove( 'Disks' )
            $vmmachine.Remove( 'Drives' )
            $vmmachine.Remove( 'NetworkAdapters' )
            $vmmachine.Remove( 'CheckpointType' )
            $vmmachine.Remove( 'AutomaticCheckpointsEnabled' )
            $vmmachine.Remove( 'AutomaticStartAction' )
            $vmmachine.Remove( 'AutomaticStartDelay' )
            $vmmachine.Remove( 'AutomaticStopAction' )
            $vmmachine.Remove( 'TpmEnabled' )

            # create the virtual machine
            $vmmachine.DependsOn          = $strVHDDepend
            $vmmachine.VhdPath            = $strVHDFile
            $vmmachine.Generation         = 2
            $vmmachine.StartupMemory      = $iMemorySize
            $vmmachine.EnableGuestService = $true

            # remove all separators from MAC Address
            if( $vmmachine.MacAddress -ne $null )
            {
                $macAddrList = [System.Collections.ArrayList]@()

                if( $vmmachine.MacAddress -is [array] )
                {
                    foreach( $macAddr in $vmmachine.MacAddress )
                    {
                        $macAddrList.Add( ($macAddr -replace '[-:\s]','') )
                    }
                }
                else
                {
                    $macAddrList.Add( ($vmmachine.MacAddress -replace '[-:\s]','') )
                }
                $vmmachine.MacAddress = $macAddrList
            }

            (Get-DscSplattedResource -ResourceName xVMHyperV -ExecutionName $vmName -Properties $vmmachine -NoInvoke).Invoke( $vmmachine )
            
            $strVMdepends = "[xVMHyperV]$vmName"

            # additional VM settings
            if( $null -ne $checkpointType -or
                $null -ne $automaticCheckpointsEnabled -or
                $null -ne $automaticStartAction -or
                $null -ne $automaticStartDelay -or
                $null -ne $automaticStopAction )
            {
                $execName = "additionalProp_$vmName"

                Script $execName
                {
                    TestScript = {
                        [boolean]$status = $true
                        $vmProp = Get-VM -VMName $using:vmName | Select-Object CheckpointType, AutomaticStartAction, AutomaticStartDelay, AutomaticStopAction, AutomaticCheckpointsEnabled
                        
                        if( $null -ne $vmProp ) 
                        {
                            Write-Verbose "VM settings of '$using:vmName':`n$vmProp"

                            if( ($null -ne $using:checkpointType              -and $vmProp.CheckpointType -ne $using:checkpointType) -or
                                ($null -ne $using:automaticStartAction        -and $vmProp.AutomaticStartAction -ne $using:automaticStartAction) -or
                                ($null -ne $using:automaticStartDelay         -and $vmProp.AutomaticStartDelay -ne $using:automaticStartDelay) -or
                                ($null -ne $using:automaticStopAction         -and $vmProp.AutomaticStopAction -ne $using:automaticStopAction) -or
                                ($null -ne $using:automaticCheckpointsEnabled -and $vmProp.AutomaticCheckpointsEnabled -ne $using:automaticCheckpointsEnabled) )
                            {
                                $status = $false
                            }
                        }
                        else
                        {
                            Write-Verbose "VM settings not available."
                            $status = $false
                        }
                        return $status
                    }
                    SetScript = {
                        $vmProps = @{
                            VMName = $using:vmName
                        }

                        if( $null -ne $using:checkpointType )
                        {
                            $vmProps.CheckpointType = $using:checkpointType
                        }
                        if( $null -ne $using:automaticStartAction )
                        {
                            $vmProps.AutomaticStartAction = $using:automaticStartAction
                        }
                        if( $null -ne $using:automaticStartDelay )
                        {
                            $vmProps.AutomaticStartDelay = $using:automaticStartDelay
                        }
                        if( $null -ne $using:automaticStopAction )
                        {
                            $vmProps.AutomaticStopAction = $using:automaticStopAction
                        }
                        if( $null -ne $using:automaticCheckpointsEnabled )
                        {
                            $vmProps.AutomaticCheckpointsEnabled = $using:automaticCheckpointsEnabled
                        }

                        Set-VM @vmProps
                    }
                    GetScript = { return @{result = 'N/A' } }
                    DependsOn = $strVMdepends
                }

                $strVMdepends = "[Script]$execName"
            }

            # security VM settings
            if( $null -ne $tpmEnabled )
            {
                $execName = "securityProp_$vmName"

                Script $execName
                {
                    TestScript = {
                        [boolean]$status = $true
                        $vmSec = Get-VMSecurity -VMName $using:vmName | Select-Object TpmEnabled, BindToHostTpm, EncryptStateAndVmMigrationTraffic, VirtualizationBasedSecurityOptOut, Shielded
                        
                        if( $null -ne $vmSec ) 
                        {
                            Write-Verbose "Security Settings of '$using:vmName':`n$vmSec"

                            if( ($null -ne $using:tpmEnabled -and $vmSec.TpmEnabled -ne $using:tpmEnabled) )
                            {
                                $status = $false
                            }
                        }
                        else
                        {
                            Write-Verbose "VM security settings not available."
                            $status = $false
                        }
                        return $status
                    }
                    SetScript = {
                        if( $using:tpmEnabled -eq $true )
                        {
                            # create a new KeyProtectore if necessary
                            $key = Get-VMKeyProtector -VMName $using:vmName
                            if( $null -eq $key -or $key.Count -lt 10 )
                            {
                                Set-VMKeyProtector -VMName $using:vmName -NewLocalKeyProtector
                            }
                            Enable-VMTPM -VMName $using:vmName
                        }
                        elseif( $using:tpmEnabled -eq $false )
                        {
                            Disable-VMTPM -VMName $using:vmName
                        }
                    }
                    GetScript = { return @{result = 'N/A' } }
                    DependsOn = $strVMdepends
                }

                $strVMdepends = "[Script]$execName"
            }

            # create specific network adapter
            foreach( $netAdapter in $networkAdapters )
            {
                # Remove Case Sensitivity of ordered Dictionary or Hashtables
                $netAdapter = @{}+$netAdapter

                $netAdapterName = $netAdapter.Name

                $netAdapter.Id        = "$($vmName)_$($netAdapterName)"
                $netAdapter.VMName    = $vmName
                $netAdapter.Ensure    = 'Present'
                $netAdapter.DependsOn = $strVMdepends

                if( $netAdapter.MacAddress -ne $null )
                {
                    # remove all separators from MAC Address
                    $netAdapter.MacAddress = $netAdapter.MacAddress -replace '[-:\s]',''
                }
    
                if( $netAdapter.NetworkSetting -ne $null )
                {
                    $netSetting = xNetworkSettings
                    {
                        IpAddress      = $netAdapter.NetworkSetting.IpAddress
                        Subnet         = $netAdapter.NetworkSetting.Subnet
                        DefaultGateway = $netAdapter.NetworkSetting.DefaultGateway
                        DnsServer      = $netAdapter.NetworkSetting.DnsServer
                    }

                    $netAdapter.NetworkSetting = $netSetting
                }

                $execName = "netadapter_$($netAdapter.Id)"

                (Get-DscSplattedResource -ResourceName xVMNetworkAdapter -ExecutionName $execName -Properties $netAdapter -NoInvoke).Invoke( $netAdapter )

                Script "$($execName)_properties"
                {
                    TestScript = {
                        $netAdapter = Get-VMNetworkAdapter $using:vmName | Where-Object { $_.Name -eq $using:netAdapterName }
                        
                        if( $null -ne $netAdapter ) 
                        {
                            Write-Verbose "Networkadapter '$using:netAdapterName': DeviceNaming is '$($netAdapter.DeviceNaming)'"

                            if( $netAdapter.DeviceNaming -eq 'On' )
                            {
                                return $true
                            }
                        }
                        else
                        {
                            Write-Verbose "Networkadapter '$using:netAdapterName' not found."
                        }
                        return $false
                    }
                    SetScript = {
                        Get-VMNetworkAdapter $using:vmName | Where-Object { $_.Name -eq $using:netAdapterName } | Set-VMNetworkAdapter -DeviceNaming On
                    }
                    GetScript = { return @{result = 'N/A' } }
                    DependsOn = "[xVMNetworkAdapter]$execName"
                }
            }

            # create further disks
            [string]$strHddDepends = $strVMDepend
            [int]$iController = 0
            [int]$iLocation   = 1
            foreach( $disk in $arrDisks )
            {
                # copy files before VM starts at first time
                if( $null -ne $disk.CopyOnce )
                {
                    throw "ERROR: CopyOnce is only supported on first disk of VM '$vmName'."
                }
                
                # create the VHD file
                if( [string]::IsNullOrWhiteSpace( $disk.Path ) )
                { 
                    $disk.Path = $strVHDPath
                }
                $strVHDName  = "$($vmName)_$($disk.Name).vhdx"
                $strVHDFile  = "$($disk.Path)\$strVHDName"
                $folderVHD   = "$($vmName)_DiskPath_$($disk.Name)"
                $strVHD      = "$($vmName)_Disk_$($disk.Name)"

                File $folderVHD
                {
                    Ensure          = 'Present'
                    Type            = 'Directory'
                    DestinationPath = $disk.Path
                    DependsOn       = $strHddDepends
                }
                if( $disk.Contains( 'CopyFrom' ) )
                {
                    $strVHDDepend = "[FILE]$strVHD"
                    File $strVHD
                    {
                        Ensure          = 'Present'
                        Type            = 'File'
                        SourcePath      = $disk.CopyFrom
                        DestinationPath = $strVHDFile
                        DependsOn       = "[File]$folderVHD"
                    }
                }
                else
                {
                    $iDiskSize    = ($disk.Size / 1GB) * 1GB
                    $strVHDDepend = "[xVHD]$strVHD"
                    xVHD $strVHD
                    {
                        Name             = $strVHDName
                        Path             = $disk.Path
                        MaximumSizeBytes = $iDiskSize
                        Generation       = 'Vhdx'
                        Type             = 'Dynamic'
                        DependsOn        = "[File]$folderVHD"
                    }
                }

                # attach the VHD file to the virtual machine
                $executionName = "$($vmName)_DiskAttach_$($disk.Name)"
                xVMHardDiskDrive $executionName
                {
                    Ensure             = 'Present'
                    VMName             = $vmName
                    Path               = $strVHDFile
                    ControllerType     = 'SCSI'
                    ControllerNumber   = $iController
                    ControllerLocation = $iLocation
                    DependsOn          = $strVMDepend, $strVHDDepend
                }

                ++$iLocation
                $strHddDepends = "[xVMHardDiskDrive]$executionName"
            }

            # create virtual drives and mount ISO files
            [string]$strDvdDepends = $strHddDepends
            $iLocation = 10
            foreach( $drive in $arrDrives )
            {
                $executionName = "$($vmName)_Drive_$($drive.Name)"

                if( $drive.Path.Length )
                {
                    xVMDvdDrive $executionName
                    {
                        Ensure             = 'Present'
                        VMName             = $vmName
                        Path               = $drive.Path
                        ControllerNumber   = $iController
                        ControllerLocation = $iLocation
                        DependsOn          = $strDvdDepends
                    }
                }
                else
                {
                    xVMDvdDrive $executionName
                    {
                        Ensure             = 'Present'
                        VMName             = $vmName
                        ControllerNumber   = $iController
                        ControllerLocation = $iLocation
                        DependsOn          = $strDvdDepends
                    }
                }

                ++$iLocation
                $strDvdDepends = "[xVMDvdDrive]$executionName"
            }

            # change boot order: first hdd -> system drive, last dvd -> OS install
            --$iLocation
            $scriptBootOrderName = "$($vmName)_ChangeBootOrder"
            Script $scriptBootOrderName
            {
                TestScript = {
                    $strPrefix  = "[$using:vmName]:"

                    $arrDVDDrives = Get-VMDvdDrive $using:vmName
                    if( ($null -eq $arrDVDDrives) -or ($arrDVDDrives.Count -lt 1) )
                    {
                        Write-Verbose "$strPrefix No DVD drives found. Boot order left unchanged."
                        return $true
                    }

                    $arrBoot = (Get-VMFirmware $using:vmName).BootOrder
                    if( ($null -eq $arrBoot) -or ($arrBoot.Count -lt 1) )
                    {
                        Write-Verbose "$strPrefix Can't get informations about the boot devices!"
                        return $false
                    }

                    # first boot device from type File is OK - skip this
                    [int]$bootIndex = 0

                    if ($arrBoot[0].BootType -eq 'File')
                    {
                        $bootIndex = 1    
                    }

                    if( $arrBoot.Count -eq (1 + $bootIndex) )
                    {
                        Write-Verbose "$strPrefix Only 1 boot device found. Boot order left unchanged."
                        return $true
                    }

                    $devBootHDD = $arrBoot[$bootIndex].Device
                    if( $null -eq $devBootHDD )
                    {
                        Write-Verbose "$strPrefix First boot device is null!"
                        return $false
                    }

                    $devBootDVD = $arrBoot[$bootIndex + 1].Device
                    if( $null -eq $devBootDVD )
                    {
                        Write-Verbose "$strPrefix Second boot device is null!"
                        return $false
                    }

                    $strMsg = "$strPrefix First boot device is set to: $($devBootHDD.ControllerType) $($devBootHDD.ControllerNumber):$($devBootHDD.ControllerLocation)"
                    if( [string]::IsNullOrEmpty($devBootHDD.Path) -eq $false ) { $strMsg += " ($($devBootHDD.Path))" }
                    Write-Verbose $strMsg

                    $strMsg = "$strPrefix Second boot device is set to: $($devBootDVD.ControllerType) $($devBootDVD.ControllerNumber):$($devBootDVD.ControllerLocation)"
                    if( [string]::IsNullOrEmpty($devBootDVD.Path) -eq $false ) { $strMsg += " ($($devBootDVD.Path))" }
                    Write-Verbose $strMsg

                    if( ($devBootHDD.ControllerNumber   -eq 0) -and
                        ($devBootHDD.ControllerLocation -eq 0) -and
                        ($devBootDVD.ControllerNumber   -eq $using:iController) -and
                        ($devBootDVD.ControllerLocation -eq $using:iLocation) )
                    {
                        Write-Verbose "$strPrefix The boot order is OK."
                        return $true
                    }
                    else
                    {
                        Write-Verbose "$strPrefix The boot order has to be modified."
                        return $false
                    }
                }
                SetScript = {
                    $strPrefix    = "[" + $using:vmName + "]:"
                    $arrHDDrives  = Get-VMHardDiskDrive $using:vmName
                    $arrDVDDrives = Get-VMDvdDrive $using:vmName

                    if( ($null -eq $arrHDDrives) -or ($arrHDDrives.Count -lt 1) )
                    {
                        Write-Error "$strPrefix Can't get informations about the hard disks!"
                        return $false
                    }

                    if( ($null -eq $arrDVDDrives) -or ($arrDVDDrives.Count -lt 1) )
                    {
                        Write-Verbose "$strPrefix No DVD drives found. Boot order left unchanged."
                        return $true
                    }

                    Set-VMFirmware $using:vmName -BootOrder $arrHDDrives[0], $arrDVDDrives[-1]
                }
                GetScript = { return @{result = 'N/A' } }
                DependsOn = $strDvdDepends
            }

            # check VM state as last step
            if( [string]::IsNullOrWhiteSpace($vmState) -eq $false )
            {
                Script "$($vmName)_State"
                {
                    TestScript = {
                        $vmObj = Get-VM -Name $using:vmName -ErrorAction Stop

                        if( $null -ne $vmObj -and $vmObj.State -eq $using:vmState )
                        {
                            return $true
                        }                    

                        return $false
                    }
                    SetScript = {
                        $vmObj = Get-VM -Name $using:vmName -ErrorAction Stop

                        if( $null -ne $vmObj -and $vmObj.State -ne $using:vmState )
                        {
                            if( $using:vmState -eq 'Running' )
                            {
                                Write-Verbose "[$using:vmName]: Starting VM '$using:vmState'"
                                Start-VM -Name $using:vmName
                            }
                            elseif( $using:vmState -eq 'Off' )
                            {
                                Write-Verbose "[$using:vmName]: Stopping VM '$using:vmState'"
                                Stop-VM -Name $using:vmName
                            }
                            elseif( $using:vmState -eq 'Paused' )
                            {
                                Write-Verbose "[$using:vmName]: Suspend VM '$using:vmState'"
                                Suspend-VM -Name $using:vmName
                            }
                        }
                    }
                    GetScript = { return @{result = 'N/A' } }
                    DependsOn = "[Script]$scriptBootOrderName"
                }
            }
        }
    }
    #endregion
}
