<#
    .SYNOPSIS
        Helper script to compile multiple DSC configurations in a single
        Windows PowerShell 5.1 process.

    .DESCRIPTION
        This script performs the expensive module imports and DSC resource
        metadata initialisation only once, then iterates over every requested
        DSC resource and compiles its MOF file.  The result is a JSON file
        written to the path specified by -ResultPath:

            [
                { "Name": "AddsDomain",           "Success": true,  "Error": null },
                { "Name": "AddsDomainController", "Success": false, "Error": "..." }
            ]

        Console output (Write-Host) streams in real-time so the caller can
        see progress as each resource is compiled.

    .PARAMETER DscResourceNames
        Comma-separated list of DSC composite resource names to compile.

    .PARAMETER ModuleName
        The name of the module under test (e.g. CommonTasks).

    .PARAMETER OutputPath
        The directory where the MOF files should be generated.

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
    $DscResourceNames,

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
    $ModulePath,

    [Parameter(Mandatory = $true)]
    [string]
    $ResultPath
)

$ErrorActionPreference = 'Stop'

# ── One-time initialisation ─────────────────────────────────────────────────
try
{
    # Filter out PowerShell 7 module paths – they contain modules (e.g.
    # Microsoft.PowerShell.Security) that are .NET Core-only and cannot be
    # loaded by Windows PowerShell 5.1, causing ConvertTo-SecureString and
    # other core cmdlets to become unavailable.
    $filteredParentPath = ($env:PSModulePath -split ';' |
            Where-Object { $_ -and $_ -notlike '*\PowerShell\7\*' }) -join ';'

    $env:PSModulePath = @(
        $ModulePath
        $RequiredModulesPath
        $filteredParentPath
    ) -join ';'

    Import-Module -Name datum -ErrorAction Stop
    Import-Module -Name DscBuildHelpers -ErrorAction Stop

    $datum = New-DatumStructure -DefinitionFile (Join-Path -Path $AssetsPath -ChildPath 'Datum.yml')

    Write-Host 'Initializing DSC Resource metadata...'
    try
    {
        Initialize-DscResourceMetaInfo -ModulePath $RequiredModulesPath -ErrorAction SilentlyContinue 2>$null
    }
    catch
    {
        Write-Warning "Initialize-DscResourceMetaInfo failed: $_"
    }
    Write-Host 'Initialization complete.'
}
catch
{
    # Fatal – cannot continue with any resource.
    Write-Error "Initialisation failed: $_"
    exit 1
}

# ── Compile each resource ────────────────────────────────────────────────────
$resourceList = $DscResourceNames -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

$results = @()

foreach ($DscResourceName in $resourceList)
{
    $result = @{ Name = $DscResourceName; Success = $false; Error = $null }

    try
    {
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

        $Error.Clear()

        $configException = $null
        try
        {
            Invoke-Expression -Command $dscConfiguration
        }
        catch
        {
            $configException = $_
        }

        $configErrors = @($Error)
        [array]::Reverse($configErrors)
        $configErrorMessages = $configErrors | ForEach-Object { $_.Exception.Message }

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
        $result.Success = $true
    }
    catch
    {
        $allErrors = @($Error)
        [array]::Reverse($allErrors)
        $allMessages = $allErrors | ForEach-Object { $_.Exception.Message }
        $result.Error = $allMessages -join "`n"
        Write-Host "Failed to compile MOF for '$DscResourceName': $($result.Error)"
    }

    $results += $result
}

# Write compilation results to the JSON file so the caller can read them.
$results | ConvertTo-Json -Depth 3 | Set-Content -Path $ResultPath -Encoding UTF8

# Exit with non-zero only if ALL resources failed (allows partial success).
$anySuccess = $results | Where-Object { $_.Success }
if (-not $anySuccess)
{
    exit 1
}
exit 0
