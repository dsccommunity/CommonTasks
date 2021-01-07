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

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName UpdateServicesDsc

    # Remove case sensitivity of ordered Dictionary or Hashtables
    if ($null -ne $Server) { $Server = @{}+$Server }

    [string]$wsusDependsOn = '[WindowsFeature]winFeatureWsusServices'

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
        DependsOn = $wsusDependsOn
    }

    if( ($null -ne $Server) -and (-not [String]::IsNullOrWhitespace($Server.SqlServer)) )
    {
        WindowsFeature winFeatureWsusSQL
        {
            Name   = 'UpdateServices-DB'
            Ensure = 'Present'
            DependsOn = $wsusDependsOn
        }
    }
    else 
    {
        WindowsFeature winFeatureWsusWiDB
        {
            Name      = 'UpdateServices-WidDB'
            Ensure    = 'Present'
            DependsOn = $wsusDependsOn
        }
    }

    if( $null -ne $Server ) 
    {
        $Server.DependsOn = $wsusDependsOn

        if( -not [string]::IsNullOrWhiteSpace( $Server.Ensure ) )
        {
            $Server.Ensure = 'Present'
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
        }

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
