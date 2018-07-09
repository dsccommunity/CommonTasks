@{
    AllNodes        = @(
        @{
            NodeName                    = 'localhost_WindowsServices'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
        }
    )

    FilesAndFolders = @{
        Items = @(
            @{
                DestinationPath = 'C:\Test.txt'
                Contents        = 'Test Content'
                Ensure          = 'Present'
                Force           = $true
                Type            = 'File'
            },
            @{
                DestinationPath = 'C:\Test'
                Ensure          = 'Present'
                Force           = $true
                Recurse         = $true
                SourcePath      = 'C:\Source'
                Type            = 'Directory'
            }
        )
    }

    WindowsFeatures = @{
        Name = 'XPS-Viewer', '-Web-Server'
    }

    RegistryValues  = @{
        Values = @(
            @{
                Key       = 'HKLM:\SOFTWARE\Microsoft\Rpc\Internet'
                ValueName = 'Ports'
                Ensure    = 'Present'
                Force     = $true
                ValueData = '60000-60100'
                ValueType = 'MultiString'
            }
        )
    }

    SecurityBase    = @{
        SecurityLevel = 2
    }

    WindowsServices = @{
        Services = @(
            @{
                Name        = 'Dummy1'
                DisplayName = 'Dummy Service'
                Path        = 'C:\Dummy.exe'
                Credential  = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
                StartupType = 'Automatic'
                State       = 'Running'
                Description = 'none'
                Ensure      = 'Present'
            },
            @{
                Name        = 'Dummy2'
                DisplayName = 'Dummy Service'
                Path        = 'C:\Dummy.exe'
                Credential  = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
                StartupType = 'Manual'
                State       = 'Stopped'
                Description = 'none'
                Ensure      = 'Present'
            }
        )
    }
}