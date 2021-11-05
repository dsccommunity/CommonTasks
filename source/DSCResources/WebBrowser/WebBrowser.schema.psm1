configuration WebBrowser
{
    param
    (
        [Parameter()]
        [Hashtable]
        $InternetExplorer,

        [Parameter()]
        [Hashtable]
        $Edge
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName GPRegistryPolicyDsc


    if( -not [string]::IsNullOrWhiteSpace($InternetExplorer.StartPage) )
    {
        RegistryPolicyFile 'InternetExplorer_HomePage'
        {
            Key        = 'Software\Policies\Microsoft\Internet Explorer\Control Panel'
            ValueName  = 'HomePage'
            TargetType = 'ComputerConfiguration'
            ValueData  = 1
            ValueType  = 'DWORD'
            Ensure     = 'Present'
        }
        
        RegistryPolicyFile 'InternetExplorer_StartPage'
        {
            Key        = 'Software\Policies\Microsoft\Internet Explorer\Main'
            ValueName  = 'Start Page'
            TargetType = 'ComputerConfiguration'
            ValueData  = $InternetExplorer.StartPage
            ValueType  = 'String'
            Ensure     = 'Present'
            DependsOn  = '[RegistryPolicyFile]InternetExplorer_HomePage'
        }

        RefreshRegistryPolicy 'InternetExplorer_RefreshPolicy'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]InternetExplorer_StartPage'
        }
    }


    if( -not [string]::IsNullOrWhiteSpace($Edge.StartPage) )
    {
        RegistryPolicyFile 'MicrosoftEdge_ShowHomeButton'
        {
            Key        = 'Software\Policies\Microsoft\Edge\Recommended'
            ValueName  = 'ShowHomeButton'
            TargetType = 'ComputerConfiguration'
            ValueData  = 1
            ValueType  = 'DWORD'
            Ensure     = 'Present'
        }

        RegistryPolicyFile 'MicrosoftEdge_HomepageLocation'
        {
            Key        = 'Software\Policies\Microsoft\Edge'
            ValueName  = 'HomepageLocation'
            TargetType = 'ComputerConfiguration'
            ValueData  = $Edge.StartPage
            ValueType  = 'String'
            Ensure     = 'Present'
            DependsOn  = '[RegistryPolicyFile]MicrosoftEdge_ShowHomeButton'
        }

        RegistryPolicyFile 'MicrosoftEdge_RestoreOnStartup'
        {
            Key        = 'Software\Policies\Microsoft\Edge'
            ValueName  = 'RestoreOnStartup'
            TargetType = 'ComputerConfiguration'
            ValueData  = 4
            ValueType  = 'DWORD'
            Ensure     = 'Present'
            DependsOn  = '[RegistryPolicyFile]MicrosoftEdge_HomepageLocation'
        }

        RegistryPolicyFile 'MicrosoftEdge_RestoreOnStartupURLs'
        {
            Key        = 'Software\Policies\Microsoft\Edge\RestoreOnStartupURLs'
            ValueName  = 1
            TargetType = 'ComputerConfiguration'
            ValueData  = $Edge.StartPage
            ValueType  = 'String'
            Ensure     = 'Present'
            DependsOn  = '[RegistryPolicyFile]MicrosoftEdge_RestoreOnStartup'
        }

        RefreshRegistryPolicy 'MicrosoftEdge_RefreshPolicy'
        {
            IsSingleInstance = 'Yes'
            DependsOn        = '[RegistryPolicyFile]MicrosoftEdge_RestoreOnStartupURLs'
        }
    } 
}
