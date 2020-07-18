configuration JeaRoles {
    param (
        [Parameter(Mandatory)]
        [hashtable[]]$Roles
    )

    Import-DscResource -ModuleName JeaDsc
    $pattern = '\\(?<Module>\w+)\\RoleCapabilities\\(?<RoleFile>\w+)\.psrc'

    foreach ($role in $Roles)
    {
        if (-not $role.ContainsKey('Ensure'))
        {
            $role.Ensure = 'Present'
        }

        if ($role.FunctionDefinitions)
        {
            $role.FunctionDefinitions = foreach ($functionDefinition in $role.FunctionDefinitions)
            {
                @{
                    Name        = $functionDefinition.Name
                    ScriptBlock = if ($functionDefinition.ScriptBlock)
                    {
                        [scriptblock]::Create($functionDefinition.ScriptBlock)
                    }
                    elseif ($functionDefinition.FilePath)
                    {
                        [scriptblock]::Create((Get-Content -Path $functionDefinition.FilePath -Raw))
                    }
                }
            }
            $role.FunctionDefinitions = ConvertTo-Expression -Object $role.FunctionDefinitions -Explore
        }

        if ($role.VisibleCmdlets)
        {
            $role.VisibleCmdlets = foreach ($visibleCmdlet in $role.VisibleCmdlets)
            {
                if ($visibleCmdlet -is [hashtable] -or $visibleCmdlet -is [System.Collections.Specialized.OrderedDictionary])
                {
                    @{
                        Name       = $visibleCmdlet.Name
                        Parameters = $visibleCmdlet.Parameters
                    }
                }
                else
                {
                    $visibleCmdlet
                }
            }
            $role.VisibleCmdlets = ConvertTo-Expression -Object $role.VisibleCmdlets -Explore
        }

        if ($role.ModulesToImport)
        {
            $role.ModulesToImport = foreach ($moduleToImport in $role.ModulesToImport)
            {
                if ($moduleToImport -is [hashtable] -or $moduleToImport -is [System.Collections.Specialized.OrderedDictionary])
                {
                    @{
                        ModuleName       = $moduleToImport.ModuleName
                        ModuleVersion = $moduleToImport.ModuleVersion
                    }
                }
                else
                {
                    $moduleToImport
                }
            }
            $role.ModulesToImport = ConvertTo-Expression -Object $role.ModulesToImport -Explore
        }

        #TODO
        #AssembliesToLoad
        #EnvironmentVariables
        #VariableDefinitions
        #AliasDefinitions

        $role.Path -match $pattern | Out-Null
        $executionName = "JeaSessionConfiguration_$($Matches.Module)_$($Matches.RoleFile)"
        (Get-DscSplattedResource -ResourceName JeaRoleCapabilities -ExecutionName $executionName -Properties $role -NoInvoke).Invoke($role)
        
    }
}
