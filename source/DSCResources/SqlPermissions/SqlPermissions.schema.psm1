configuration SqlPermissions {
    param (
        [Parameter()]
        [string]
        $DefaultInstanceName = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Values
    )

    Import-DscResource -ModuleName SqlServerDsc -Name SqlPermission, ServerPermission

    function Get-Permission
    {
        param (
            [Parameter()]
            [hashtable]
            $permissionValues
        )

        $permission = $null

        if ($null -ne $permissionValues)
        {
            $grant = @()
            $grantWithGrant = @()
            $deny = @()

            if ($permissionValues.Grant)
            {
                $grant += $permissionValues.Grant
            }

            if ($permissionValues.GrantWithGrant)
            {
                $grantWithGrant += $permissionValues.GrantWithGrant
            }

            if ($permissionValues.Deny)
            {
                $deny += $permissionValues.Deny
            }

            $permission = @(
                ServerPermission
                {
                    State      = 'Grant'
                    Permission = $grant
                }
                ServerPermission
                {
                    State      = 'GrantWithGrant'
                    Permission = $grantWithGrant
                }
                ServerPermission
                {
                    State      = 'Deny'
                    Permission = $deny
                }
            )
        }

        return $permission
    }


    foreach ($value in $Values)
    {
        if (-not $value.InstanceName)
        {
            $value.InstanceName = $DefaultInstanceName
        }

        # Refactored permissions with SqlServerDsc 16.0.0
        # see https://github.com/dsccommunity/SqlServerDsc/wiki/SqlPermission

        $permission          = Get-Permission -permissionValues $value.Permission
        $permissionToInclude = Get-Permission -permissionValues $value.PermissionToInclude
        $permissionToExclude = Get-Permission -permissionValues $value.PermissionToExclude

        $executionName = "$($value.InstanceName)_$($value.Name)" -replace '[().:\s]', '_'

        SqlPermission $executionName
        {
            InstanceName         = $value.InstanceName
            Name                 = $value.Name
            ServerName           = $value.ServerName
            Credential           = $value.Credential
            Permission           = $permission
            PermissionToInclude  = $permissionToInclude
            PermissionToExclude  = $permissionToExclude
        }
    }
}
