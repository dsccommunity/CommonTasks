configuration AzureConnectedMachineAgent
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        [Parameter(Mandatory = $true)]
        [string]
        $TenantId,

        [Parameter(Mandatory = $true)]
        [string]
        $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory = $true)]
        [string]
        $Location,

        [Parameter()]
        $Tags,

        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName AzureConnectedMachineDsc

    xPackage AzureHIMDService
        {
            Name        = 'Azure Connected Machine Agent'
            Ensure      = 'Present'
            ProductId   = ''
            Path        = 'https://aka.ms/AzureConnectedMachineAgent'

        }

    xService HIMDS
        {
            Ensure      = 'Present'
            Name        = 'HIMDS'
            State       = 'Running'
            DependsOn   = '[xPackage]AzureHIMDService'
        }

    AzureConnectedMachineAgentDsc Connect
        {
            TenantId        = $TenantId
            SubscriptionId  = $SubscriptionId
            ResourceGroup   = $ResourceGroup
            Location        = $Location
            Tags            = $Tags
            Credential      = $Credential
            DependsOn       = '[xService]HIMDS'
        }





}
