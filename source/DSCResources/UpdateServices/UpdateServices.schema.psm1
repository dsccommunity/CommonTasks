configuration UpdateServices
{
    param
    (
        [Parameter()]
        [hashtable]
        $Server,

        [Parameter()]
        [hashtable]
        $Cleanup,

        [Parameter()]
        [hashtable[]]
        $ApprovalRules
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName UpdateServicesDsc

    # Remove case sensitivity of ordered Dictionary or Hashtables
    if ($null -ne $Server) { $Server = @{}+$Server }

    WindowsFeature winFeatureWsusServices
    {
        Name   = 'UpdateServices-Services'
        Ensure = 'Present'
    }

    WindowsFeature winFeatureWsusRSAT
    {
        Ensure = 'Present'
        Name = 'UpdateServices-RSAT'
        IncludeAllSubFeature = $True
        DependsOn = '[WindowsFeature]winFeatureWsusServices'
    }

    [string]$wsusDependsOn = '[WindowsFeature]winFeatureWsusRSAT'

    if( ($null -ne $Server) -and (-not [String]::IsNullOrWhitespace($Server.SqlServer)) )
    {
        WindowsFeature winFeatureWsusSQL
        {
            Name   = 'UpdateServices-DB'
            Ensure = 'Present'
            DependsOn = $wsusDependsOn
        }

        $wsusDependsOn = '[WindowsFeature]winFeatureWsusSQL'
    }
    else 
    {
        WindowsFeature winFeatureWsusWiDB
        {
            Name      = 'UpdateServices-WidDB'
            Ensure    = 'Present'
            DependsOn = $wsusDependsOn
        }

        $wsusDependsOn = '[WindowsFeature]winFeatureWsusWiDB'
    }

    if( $null -ne $Server ) 
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $Server = @{}+$Server

        if( -not [string]::IsNullOrWhiteSpace( $Server.Ensure ) )
        {
            $Server.Ensure = 'Present'
        }

        if( [string]::IsNullOrWhiteSpace( $Server.UpdateImprovementProgram ) )
        {
            $Server.UpdateImprovementProgram = $false
        }
        
        if( [string]::IsNullOrWhiteSpace( $Server.Synchronize ) )
        {
            $Server.Synchronize = $false
        }

        if( [string]::IsNullOrWhiteSpace( $Server.SynchronizeAutomatically ) )
        {
            $Server.SynchronizeAutomatically = $false
        }

        if( [string]::IsNullOrWhiteSpace( $Server.ClientTargetingMode ) )
        {
            $Server.ClientTargetingMode = 'Client'
        }

        # create a specified content directory
        if( -not [string]::IsNullOrWhiteSpace( $Server.ContentDir ) )
        {
            File wsusContentDir
            {
                Ensure          = "Present"
                Type            = "Directory"
                Recurse         = $false
                SourcePath      = $null
                Force           = $true
                MatchSource     = $false
                DestinationPath = $Server.ContentDir
                DependsOn       = $wsusDependsOn
            }

            $wsusDependsOn = '[File]wsusContentDir'
        }

        # make a reboot before WSUS setup
        if( (-not [string]::IsNullOrWhiteSpace( $Server.ForceRebootBefore )) -and ($Server.ForceRebootBefore -eq 'True') )
        {
            $rebootKeyName = 'HKLM:\SOFTWARE\DSC Community\CommonTasks\RebootRequests'
            $rebootVarName = 'RebootBefore_UpdateServices_Server'
    
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
                DependsOn = $wsusDependsOn
            }        
    
            $wsusDependsOn = "[Script]$rebootVarName"
        }

        $Server.DependsOn = $wsusDependsOn

        $Server.Remove('ForceRebootBefore')
    
        (Get-DscSplattedResource -ResourceName UpdateServicesServer -ExecutionName "wsusSrv" -Properties $Server -NoInvoke).Invoke($Server)

        $wsusDependsOn = '[UpdateServicesServer]wsusSrv'
    }

    if( $null -ne $ApprovalRules ) 
    {
        foreach( $rule in $ApprovalRules.GetEnumerator() ) 
        {
            # Remove case sensitivity of ordered Dictionary or Hashtables
            $rule = @{}+$rule

            $rule.DependsOn = $wsusDependsOn

            if( -not [string]::IsNullOrWhiteSpace( $rule.Ensure ) )
            {
                $rule.Ensure = 'Present'
            }
    
            (Get-DscSplattedResource -ResourceName UpdateServicesApprovalRule -ExecutionName "'wsus$($rule.Name)'" -Properties $rule -NoInvoke).Invoke($rule)
        }
    }

    if( $null -ne $Cleanup ) 
    {
        # Remove case sensitivity of ordered Dictionary or Hashtables
        $Cleanup = @{}+$Cleanup

        $CleanUp.DependsOn = $wsusDependsOn

        if( -not [string]::IsNullOrWhiteSpace( $CleanUp.Ensure ) )
        {
            $CleanUp.Ensure = 'Present'
        }

        (Get-DscSplattedResource -ResourceName UpdateServicesCleanup  -ExecutionName "wsusCleanup" -Properties $CleanUp -NoInvoke).Invoke($CleanUp)
    }
}
