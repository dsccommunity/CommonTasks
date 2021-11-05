configuration ExchangeConfiguration {
    param
    (
        [PSCredential]$ShellCreds,
        [PSCredential]$CertCreds,
        [PSCredential]$FileCopyCreds,

        [Parameter(Mandatory)]
        [string]$ExternalNamespace,

        [Parameter(Mandatory)]
        [string]$InternalNamespace,

        [Parameter(Mandatory)]
        [string]$AutoDiscoverSiteScope
        
    )
    
    #Import required DSC Modules
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xExchange
    Import-DscResource -Module xWebAdministration
      
    ###CAS specific settings###
    #The following section shows how to configure commonly configured URL's on various virtual directories
    xExchClientAccessServer CAS
    {
        Identity                       = $Node.NodeName
        Credential                     = $ShellCreds
        AutoDiscoverServiceInternalUri = "https://$InternalNamespace/autodiscover/autodiscover.xml"
        AutoDiscoverSiteScope          = $AutoDiscoverSiteScope
    }
    
    xExchActiveSyncVirtualDirectory ASVdir
    {
        Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/Microsoft-Server-ActiveSync"
        InternalUrl = "https://$InternalNamespace/Microsoft-Server-ActiveSync"
    }

    xExchEcpVirtualDirectory ECPVDir
    {
        Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/ecp"
        InternalUrl = "https://$InternalNamespace/ecp"
    }
    
    xExchMapiVirtualDirectory MAPIVdir
    {
        Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
        Credential               = $ShellCreds
        ExternalUrl              = "https://$ExternalNamespace/mapi"
        InternalUrl              = "https://$InternalNamespace/mapi"
        IISAuthenticationMethods = 'Ntlm', 'OAuth', 'Negotiate'
    }   
    
    xExchOabVirtualDirectory OABVdir
    {
        Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/oab"
        InternalUrl = "https://$InternalNamespace/oab"
    }
    
    xExchOutlookAnywhere OAVdir
    {
        Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
        Credential                         = $ShellCreds
        ExternalClientAuthenticationMethod = 'Negotiate'
        ExternalClientsRequireSSL          = $true
        ExternalHostName                   = $ExternalNamespace
        IISAuthenticationMethods           = 'Basic', 'Ntlm', 'Negotiate'
        InternalClientAuthenticationMethod = 'Ntlm'
        InternalClientsRequireSSL          = $true
        InternalHostName                   = $InternalNamespace
    }

    #Sets OWA url's, and enables Lync integration on the OWA front end directory
    xExchOwaVirtualDirectory OWAVdir
    {
        Identity    = "$($Node.NodeName)\owa (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/owa"
        InternalUrl = "https://$InternalNamespace/owa"
        #InstantMessagingEnabled               = $true
        #InstantMessagingCertificateThumbprint = $dagSettings.Thumbprint
        #InstantMessagingServerName            = $casSettingsPerSite.InstantMessagingServerName
        #InstantMessagingType                  = 'Ocs'
    
        #DependsOn                             = '[xExchExchangeCertificate]Certificate' #Can't configure the IM cert until it's valid
    }
    
    xExchWebServicesVirtualDirectory EWSVdir
    {
        Identity             = "$($Node.NodeName)\EWS (Default Web Site)"
        Credential           = $ShellCreds
        ExternalUrl          = "https://$ExternalNamespace/ews/exchange.asmx"
        InternalNLBBypassUrl = "https://$($Node.NodeName).contoso.com/ews/exchange.asmx"
        InternalUrl          = "https://$InternalNamespace/ews/exchange.asmx"
    }
    
}