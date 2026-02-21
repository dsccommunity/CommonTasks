<#
    .SYNOPSIS
        Helper script to compile DSC configurations in Windows PowerShell 5.1.

    .DESCRIPTION
        This script is called from the Pester tests when running under PowerShell 7+
        to avoid the WinPSCompatSession remoting issue where Tuple types get
        deserialized to ArrayList, breaking the Configuration keyword's
        ResourceModuleTuplesToImport parameter.

    .PARAMETER DscResourceName
        The name of the DSC composite resource to compile.

    .PARAMETER ModuleName
        The name of the module under test (e.g. CommonTasks).

    .PARAMETER OutputPath
        The directory where the MOF file should be generated.

    .PARAMETER AssetsPath
        The path to the test Assets directory containing Datum.yml and Config data.

    .PARAMETER RequiredModulesPath
        The path to the RequiredModules directory.

    .PARAMETER ModulePath
        The path to the built module output directory.
#>
param
(
    [Parameter(Mandatory = $true)]
    [string]
    $DscResourceName,

    [Parameter(Mandatory = $true)]
    [string]
    $ModuleName,

    [Parameter(Mandatory = $true)]
    [string]
    $OutputPath,

    [Parameter(Mandatory = $true)]
    [string]
    $AssetsPath,

    [Parameter(Mandatory = $true)]
    [string]
    $RequiredModulesPath,

    [Parameter(Mandatory = $true)]
    [string]
    $ModulePath
)

$ErrorActionPreference = 'Stop'

try
{
    # Set up PSModulePath to find all required modules
    $env:PSModulePath = @(
        $ModulePath
        $RequiredModulesPath
        $env:PSModulePath
    ) -join ';'

    Import-Module -Name datum -ErrorAction Stop
    Import-Module -Name DscBuildHelpers -ErrorAction Stop

    $datum = New-DatumStructure -DefinitionFile (Join-Path -Path $AssetsPath -ChildPath 'Datum.yml')

    Write-Host 'Initializing DSC Resource metadata...'
    # Suppress benign 'second CIM class definition' / empty-path errors caused by
    # modules existing in both RequiredModules and a system module path.
    try
    {
        Initialize-DscResourceMetaInfo -ModulePath $RequiredModulesPath -ErrorAction SilentlyContinue 2>$null
    }
    catch
    {
        Write-Warning "Initialize-DscResourceMetaInfo failed: $_"
    }

    $nodeData = @{
        NodeName                    = "localhost_$DscResourceName"
        PSDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser        = $true
    }

    $configurationData = @{
        AllNodes = @($nodeData)
        Datum    = $datum
    }

    $dscConfiguration = @"
configuration "Config_$DscResourceName" {

    Import-DscResource -Module $ModuleName -Name $DscResourceName

    node "localhost_$DscResourceName" {

        `$data = `$configurationData.Datum.Config."$DscResourceName"
        if (-not `$data)
        {
            `$data = @{}
        }

        (Get-DscSplattedResource -ResourceName $DscResourceName -ExecutionName $DscResourceName -Properties `$data -NoInvoke).Invoke(`$data)
    }
}
"@

    # Clear errors before defining the configuration so we can detect
    # errors from the DSC Configuration keyword (e.g. invalid property names,
    # missing modules, etc.).
    $Error.Clear()

    # The Configuration keyword may throw terminating errors.  Wrap it in its
    # own try/catch so we can still inspect $Error for the full error chain
    # (the first error in the chain is often the root cause, while the
    # terminating error is a secondary consequence like "not recognized").
    $configException = $null
    try
    {
        Invoke-Expression -Command $dscConfiguration
    }
    catch
    {
        $configException = $_
    }

    # Collect all errors accumulated during configuration definition.
    # $Error is in reverse chronological order; reverse it so the root cause
    # (the earliest error) appears first.
    $configErrors = @($Error)
    [array]::Reverse($configErrors)
    $configErrorMessages = $configErrors | ForEach-Object { $_.Exception.Message }

    # Check whether the configuration function was actually created.
    $configCmd = Get-Command "Config_$DscResourceName" -ErrorAction SilentlyContinue
    if (-not $configCmd)
    {
        if ($configErrorMessages)
        {
            throw "Configuration definition failed for '$DscResourceName':`n$($configErrorMessages -join "`n")"
        }
        if ($configException)
        {
            throw "Configuration definition failed for '$DscResourceName': $($configException.Exception.Message)"
        }
        throw "Configuration 'Config_$DscResourceName' was not created. The DSC resource '$DscResourceName' may have errors in its schema definition."
    }

    & "Config_$DscResourceName" -ConfigurationData $configurationData -OutputPath $OutputPath -ErrorAction Stop

    Write-Host "Successfully compiled MOF for '$DscResourceName'"
    exit 0
}
catch
{
    # Collect all errors (reverse so root cause is first) for the full picture.
    $allErrors = @($Error)
    [array]::Reverse($allErrors)
    $allMessages = $allErrors | ForEach-Object { $_.Exception.Message }
    $errorDetail = $allMessages -join "`n"
    Write-Error "Failed to compile DSC configuration '$DscResourceName':`n$errorDetail"
    exit 1
}
