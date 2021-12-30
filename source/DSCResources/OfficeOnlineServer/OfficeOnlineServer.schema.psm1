configuration OfficeOnlineServer
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword')]

    param (
        [Parameter()]
        [uri]
        $ExternalUrl,

        [Parameter()]
        [uri]
        $InternalUrl,

        [Parameter()]
        [string]
        $CertificateName,

        [Parameter()]
        [switch]
        $AllowHttp,

        [Parameter()]
        [bool]
        $EditingEnabled,

        [Parameter()]
        [bool]
        $AllowCEIP,

        [Parameter()]
        [bool]
        $AllowHttpSecureStoreConnections,

        [Parameter()]
        [string]
        $CacheLocation,

        [Parameter()]
        [int]
        $CacheSizeInGB,

        [Parameter()]
        [string]
        $RenderingLocalCacheLocation,

        [Parameter()]
        [string]
        $LogLocation,

        [Parameter()]
        [int]
        $MaxMemoryCacheSizeInMB,

        [Parameter()]
        [bool]
        $ClipartEnabled,

        [Parameter()]
        [ValidateSet('VerboseEX', 'Verbose', 'Medium', 'High', 'Monitorable', 'Unexpected', 'None')]
        [string]
        $LogVerbosity = 'Medium',

        [Parameter()]
        [string]
        $MicrosoftIdentityExtensionsPath,

        [Parameter()]
        [string]
        $DotNet48FrameworkPath,

        [Parameter()]
        [string]
        $VcRedistributable2013Path,

        [Parameter()]
        [string]
        $VcRedistributable2013ProductId,

        [Parameter()]
        [string]
        $VcRedistributable20152019Path,

        [Parameter()]
        [string]
        $VcRedistributable20152019ProductId,

        [Parameter()]
        [hashtable[]]
        $LanguagePacks,

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $MasterServer
    )
    function Sync-Parameter
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars')]
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory = $true)]
            [ValidateScript( {
                    $_ -is [System.Management.Automation.FunctionInfo] -or
                    $_ -is [System.Management.Automation.CmdletInfo] -or
                    $_ -is [System.Management.Automation.ExternalScriptInfo] -or
                    $_.GetType().FullName -eq 'Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo' -or
                    $_.psobject.TypeNames[0] -eq 'Deserialized.Selected.Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo'
                })]
            [object]
            $Command,

            [Parameter()]
            [hashtable]
            $Parameters,

            [Parameter()]
            [switch]
            $ConvertValue
        )

        if (-not $PSBoundParameters.ContainsKey('Parameters'))
        {
            $Parameters = ([hashtable]$ALBoundParameters).Clone()
        }
        else
        {
            $Parameters = ([hashtable]$Parameters).Clone()
        }

        $commonParameters = [System.Management.Automation.Internal.CommonParameters].GetProperties().Name
        $commandParameterKeys = if ($Command.GetType().FullName -eq 'Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo' -or
            $Command.psobject.TypeNames[0] -eq 'Deserialized.Selected.Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo')
        {
            $Command.Properties.Name
        }
        else
        {
            $Command.Parameters.Keys.GetEnumerator() | ForEach-Object { $_ }
        }

        $parameterKeys = $Parameters.Keys.GetEnumerator() | ForEach-Object { $_ }

        $keysToRemove = Compare-Object -ReferenceObject $commandParameterKeys -DifferenceObject $parameterKeys |
            Select-Object -ExpandProperty InputObject

        $keysToRemove = $keysToRemove + $commonParameters | Select-Object -Unique #remove the common parameters

        foreach ($key in $keysToRemove)
        {
            $Parameters.Remove($key)
        }

        if ($ConvertValue.IsPresent)
        {
            $keysToUpdate = @{}
            foreach ($kvp in $Parameters.GetEnumerator())
            {
                if (-not $kvp.Value) # $null or empty string will not trip up conversion
                {
                    continue
                }

                $targetType = $Command.Parameters[$kvp.Key].ParameterType
                $sourceType = $kvp.Value.GetType()
                $targetValue = $kvp.Value -as $targetType

                if (-not $targetValue -and $targetType.ImplementedInterfaces -contains [Collections.IList])
                {
                    $targetValue = $targetType::new()
                    foreach ($v in $kvp.Value)
                    {
                        $targetValue.Add($v)
                    }
                }

                if (-not $targetValue -and $targetType.ImplementedInterfaces -contains [Collections.IDictionary] )
                {
                    $targetValue = $targetType::new()
                    foreach ($k in $kvp.Value.GetEnumerator())
                    {
                        $targetValue.Add($k.Key, $k.Value)
                    }
                }

                if (-not $targetValue -and ($sourceType.ImplementedInterfaces -contains [Collections.IList] -and $targetType.ImplementedInterfaces -notcontains [Collections.IList]))
                {
                    Write-Verbose -Message "Value of source parameter $($kvp.Key) is a collection, but target parameter is not. Selecting first object"
                    $targetValue = $kvp.Value | Select-Object -First 1
                }

                if (-not $targetValue)
                {
                    Write-Error -Message "Conversion of source parameter $($kvp.Key) (Type: $($sourceType.FullName)) to type $($targetType.FullName) was impossible"
                    return
                }

                $keysToUpdate[$kvp.Key] = $targetValue
            }
        }

        if ($keysToUpdate)
        {
            foreach ($kvp in $keysToUpdate.GetEnumerator())
            {
                $Parameters[$kvp.Key] = $kvp.Value
            }
        }

        if ($PSBoundParameters.ContainsKey('Parameters'))
        {
            $Parameters
        }
        else
        {
            $global:ALBoundParameters = $Parameters
        }
    }

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OfficeOnlineServerDsc
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    if (-not $ExternalUrl -and -not $InternalUrl)
    {
        Write-Error 'Either "$ExternalUrl" or "$InternalUrl" must be defined'
        return
    }

    if ($LogLocation)
    {
        File LogFolder
        {
            Ensure          = 'Present'
            DestinationPath = $LogLocation
            Type            = 'Directory'
        }
    }

    xWindowsFeatureSet OfficeOnlineServer
    {
        Ensure = 'Present'
        Name   = @(
            'Web-Server',
            'Web-Mgmt-Tools',
            'Web-Mgmt-Console',
            'Web-WebServer',
            'Web-Common-Http',
            'Web-Default-Doc',
            'Web-Static-Content',
            'Web-Performance',
            'Web-Stat-Compression',
            'Web-Dyn-Compression',
            'Web-Security',
            'Web-Filtering',
            'Web-Windows-Auth',
            'Web-App-Dev',
            'Web-Net-Ext45',
            'Web-Asp-Net45',
            'Web-ISAPI-Ext',
            'Web-ISAPI-Filter',
            'Web-Includes',
            'NET-Framework-Features',
            'NET-Framework-Core',
            'NET-HTTP-Activation',
            'NET-Non-HTTP-Activ',
            'NET-WCF-HTTP-Activation45',
            'Server-Media-Foundation',
            'Windows-Identity-Foundation'
        )
    }

    xService WMIPerformanceAdapter
    {
        DependsOn   = '[xWindowsFeatureSet]OfficeOnlineServer'
        Name        = 'wmiApSrv'
        State       = 'Running'
        StartupType = 'Automatic'
    }

    $softwareDependsOn = @('[xWindowsFeatureSet]OfficeOnlineServer')
    if ($MicrosoftIdentityExtensionsPath)
    {
        $softwareDependsOn += '[xPackage]Microsoft.IdentityModel.Extention.dll'
        xPackage 'Microsoft.IdentityModel.Extention.dll'
        {
            Ensure    = 'Present'
            Name      = 'Microsoft Identity Extensions'
            Path      = $MicrosoftIdentityExtensionsPath
            ProductId = 'F99F24BF-0B90-463E-9658-3FD2EFC3C991'
        }
    }

    if ($DotNet48FrameworkPath)
    {
        $softwareDependsOn += '[xPackage]DotNetFramework48'
        xPackage DotNetFramework48
        {
            Ensure                     = 'Present'
            Name                       = 'Microsoft .NET Framework 4.8'
            Path                       = $DotNet48FrameworkPath
            ProductId                  = ''
            Arguments                  = '/q /norestart'
            InstalledCheckRegHive      = 'LocalMachine'
            InstalledCheckRegKey       = 'SOFTWARE\DscInstallations\'
            InstalledCheckRegValueName = 'DotNet48'
            InstalledCheckRegValueData = '4.8.03761'
            CreateCheckRegValue        = $true
        }
    }

    if ($VcRedistributable20152019Path)
    {
        $softwareDependsOn += '[xPackage]vcredist2015-2019'
        xPackage vcredist2015-2019
        {
            Ensure    = 'Present'
            Name      = 'Microsoft Visual C++ 2015-2019 Redistributable (x64)'
            Path      = $VcRedistributable20152019Path
            ProductId = $VcRedistributable20152019ProductId
            Arguments = '/install /quiet /norestart'
        }
    }

    if ($VcRedistributable2013Path)
    {
        $softwareDependsOn += '[xPackage]vcredist2013'
        xPackage vcredist2013
        {
            Ensure    = 'Present'
            Name      = 'Microsoft Visual C++ 2013 Redistributable (x64)'
            Path      = $VcRedistributable2013Path
            ProductId = $VcRedistributable2013ProductId
            Arguments = '/install /quiet /norestart'
        }
    }

    OfficeOnlineServerInstall InstallBinaries
    {
        Ensure    = "Present"
        Path      = $Path
        DependsOn = $softwareDependsOn
    }

    $dependsOnInstallAndLanguagePack = @()
    foreach ($languagePack in $LanguagePacks)
    {
        $dependsOnInstallAndLanguagePack += "[OfficeOnlineServerInstallLanguagePack]$($languagePack.Language)"
        OfficeOnlineServerInstallLanguagePack $languagePack.Language
        {
            Ensure    = 'Present'
            BinaryDir = $languagePack.BinaryDir
            Language  = $languagePack.Language
            DependsOn = '[OfficeOnlineServerInstall]InstallBinaries'
        }
    }
    $dependsOnInstallAndLanguagePack += '[OfficeOnlineServerInstall]InstallBinaries'

    if ($MasterServer -eq $node.NodeName)
    {
        #Get-DscResource cannot be called inside a configuration, hence the background job
        $resource = Start-Job -ScriptBlock { Get-DscResource -Name OfficeOnlineServerFarm | Select-Object -Property Name, Properties } | Receive-Job -AutoRemoveJob -Wait
        $param = Sync-Parameter -Parameters $PSBoundParameters -Command $resource
        $param.Add('DependsOn', $dependsOnInstallAndLanguagePack)

        (Get-DscSplattedResource -ResourceName OfficeOnlineServerFarm -ExecutionName CreateFarm -Properties $param -NoInvoke).Invoke($param)

        xService OfficeOnline
        {
            DependsOn    = '[OfficeOnlineServerFarm]CreateFarm'
            Name         = 'WACSM'
            State        = 'Running'
            Dependencies = 'wmiApSrv'
        }
    }
    else
    {
        WaitForAll MasterServer
        {
            DependsOn        = $dependsOnInstallAndLanguagePack
            NodeName         = $MasterServer
            ResourceName     = '[OfficeOnlineServerFarm]CreateFarm'
            RetryIntervalSec = 30
            RetryCount       = 30
        }

        OfficeOnlineServerMachine JoinFarm
        {
            Ensure        = 'Present'
            Roles         = 'All'
            MachineToJoin = $node.NodeName
            DependsOn     = '[WaitForAll]MasterServer'
        }

        Service OfficeOnline
        {
            DependsOn    = '[OfficeOnlineServerMachine]JoinFarm'
            Name         = 'WACSM'
            State        = 'Running'
            Dependencies = 'wmiApSrv'
        }
    }
}
