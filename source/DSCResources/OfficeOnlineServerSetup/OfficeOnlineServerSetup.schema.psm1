configuration OfficeOnlineServerSetup
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]

    param (
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
        $WindowsFeatureSourcePath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName OfficeOnlineServerDsc
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    if ($LogLocation)
    {
        File LogFolder
        {
            Ensure          = 'Present'
            DestinationPath = $LogLocation
            Type            = 'Directory'
        }
    }

    WindowsFeature NetFx35
    {
        Name   = 'Net-Framework-Core'
        Ensure = 'Present'
        Source = $WindowsFeatureSourcePath
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
            'NET-HTTP-Activation',
            'NET-Non-HTTP-Activ',
            'NET-WCF-HTTP-Activation45',
            'Server-Media-Foundation',
            'Windows-Identity-Foundation'
        )
    }

    xService WMIPerformanceAdapter
    {
        DependsOn   = '[xWindowsFeatureSet]OfficeOnlineServer', '[WindowsFeature]NetFx35'
        Name        = 'wmiApSrv'
        State       = 'Running'
        StartupType = 'Automatic'
    }

    $softwareDependsOn = @('[xService]WMIPerformanceAdapter')
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
        Ensure    = 'Present'
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

}
