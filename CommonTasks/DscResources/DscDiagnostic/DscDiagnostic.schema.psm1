function Get-DscConfigurationVersion
{
    New-Object -TypeName PSObject -Property @{
        Version = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscTagging -Name Version
        Environment = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscTagging -Name Environment
        GitCommitId = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscTagging -Name GitCommitId
        BuildDate = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\DscTagging -Name BuildDate
    }
}

function Test-DscConfiguration {
    PSDesiredStateConfiguration\Test-DscConfiguration -Detailed -Verbose
}

function Update-DscConfiguration {
    PSDesiredStateConfiguration\Update-DscConfiguration -Wait -Verbose
}

function Get-DscLcmControllerSummary {
    Import-Csv -Path C:\ProgramData\Dsc\LcmController\LcmControllerSummary.txt
}

function Start-DscConfiguration {
    PSDesiredStateConfiguration\Start-DscConfiguration -UseExisting -Wait -Verbose
}

#-------------------------------------------------------------------------------------------

Configuration DscDiagnostic {

    Import-DscResource -ModuleName JeaDsc

    $visibleFunctions = 'Test-DscConfiguration', 'Get-DscConfigurationVersion', 'Update-DscConfiguration', 'Get-DscLcmControllerSummary', 'Start-DscConfiguration'
    $functionDefinitions = @()
    foreach ($visibleFunction in $visibleFunctions) {
        $functionDefinitions += @{
            Name = $visibleFunction
            ScriptBlock = (Get-Command -Name $visibleFunction).ScriptBlock
        } | ConvertTo-Expression
    }

    JeaRoleCapabilities ReadDiagnosticsRole
    {
        Path = 'C:\Program Files\WindowsPowerShell\Modules\DscDiagnostics\RoleCapabilities\ReadDiagnosticsRole.psrc'
        VisibleFunctions = $visibleFunctions
        FunctionDefinitions = $functionDefinitions
    }
    
    JeaSessionConfiguration DscEndpoint
    {
        Ensure = 'Present'
        DependsOn = '[JeaRoleCapabilities]ReadDiagnosticsRole'
        Name = 'DSC'
        RoleDefinitions = '@{ Everyone = @{ RoleCapabilities = "ReadDiagnosticsRole" } }'
        SessionType = 'RestrictedRemoteServer'
        ModulesToImport = 'PSDesiredStateConfiguration'
    }
}
