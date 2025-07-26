configuration ExchangeConfiguration {
    param
    (
        [Parameter()]
        [PSCredential]
        $ShellCreds,

        [Parameter()]
        [PSCredential]
        $CertCreds,

        [Parameter()]
        [PSCredential]
        $FileCopyCreds,

        [Parameter(Mandatory = $true)]
        [string]
        $ExternalNamespace,

        [Parameter(Mandatory = $true)]
        [string]
        $InternalNamespace,

        [Parameter(Mandatory = $true)]
        [string]
        $AutoDiscoverSiteScope
    )

    #Import required DSC Modules
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ExchangeDsc

    ###CAS specific settings###
    #The following section shows how to configure commonly configured URL's on various virtual directories
    ExchClientAccessServer CAS
    {
        Identity                       = $Node.NodeName
        Credential                     = $ShellCreds
        AutoDiscoverServiceInternalUri = "https://$InternalNamespace/autodiscover/autodiscover.xml"
        AutoDiscoverSiteScope          = $AutoDiscoverSiteScope
    }

    ExchActiveSyncVirtualDirectory ASVdir
    {
        Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/Microsoft-Server-ActiveSync"
        InternalUrl = "https://$InternalNamespace/Microsoft-Server-ActiveSync"
    }

    ExchEcpVirtualDirectory ECPVDir
    {
        Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/ecp"
        InternalUrl = "https://$InternalNamespace/ecp"
    }

    ExchMapiVirtualDirectory MAPIVdir
    {
        Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
        Credential               = $ShellCreds
        ExternalUrl              = "https://$ExternalNamespace/mapi"
        InternalUrl              = "https://$InternalNamespace/mapi"
        IISAuthenticationMethods = 'Ntlm', 'OAuth', 'Negotiate'
    }

    ExchOabVirtualDirectory OABVdir
    {
        Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/oab"
        InternalUrl = "https://$InternalNamespace/oab"
    }

    ExchOutlookAnywhere OAVdir
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
    ExchOwaVirtualDirectory OWAVdir
    {
        Identity    = "$($Node.NodeName)\owa (Default Web Site)"
        Credential  = $ShellCreds
        ExternalUrl = "https://$ExternalNamespace/owa"
        InternalUrl = "https://$InternalNamespace/owa"
        #InstantMessagingEnabled               = $true
        #InstantMessagingCertificateThumbprint = $dagSettings.Thumbprint
        #InstantMessagingServerName            = $casSettingsPerSite.InstantMessagingServerName
        #InstantMessagingType                  = 'Ocs'

        #DependsOn                             = '[ExchExchangeCertificate]Certificate' #Can't configure the IM cert until it's valid
    }

    ExchWebServicesVirtualDirectory EWSVdir
    {
        Identity             = "$($Node.NodeName)\EWS (Default Web Site)"
        Credential           = $ShellCreds
        ExternalUrl          = "https://$ExternalNamespace/ews/exchange.asmx"
        InternalNLBBypassUrl = "https://$($Node.NodeName).contoso.com/ews/exchange.asmx"
        InternalUrl          = "https://$InternalNamespace/ews/exchange.asmx"
    }

}
