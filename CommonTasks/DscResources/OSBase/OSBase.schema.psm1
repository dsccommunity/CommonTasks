configuration OSBase
{
    param
    (
        [switch]
        $NoDomainJoin
    )

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 7.1.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.4.0.0

    $JoinOu = "{0},{1}" -f (Lookup JoinOU), (lookup Domain/DomainDn)

    if (-not $NoDomainJoin)
    {
        $joinUser = Lookup Domain/DomainJoinAccount
    
        Computer DomainJoin 
        {
            Name        = Lookup NodeName
            DomainName  = Lookup Domain/DomainFqdn
            JoinOU     = $JoinOu
            Credential = $joinUser
            Description = Lookup Description
        }
    }
    
    Registry enableRDP
    {
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server"
        valueData = 0
        ValueName = "fDenyTSConnections"
        ValueType = "DWORD"
    }
}
