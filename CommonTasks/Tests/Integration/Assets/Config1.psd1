@{
    AllNodes               = @(
        @{
            NodeName                    = 'localhost_WindowsServices'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName    = 'localhost_DscTagging'
            Environment = 'Dev'
        }
    )

    FilesAndFolders        = @{
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

    WindowsFeatures        = @{
        Name = 'XPS-Viewer', '-Web-Server'
    }

    RegistryValues         = @{
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

    SecurityBase           = @{
        SecurityLevel = 2
    }

    WindowsServices        = @{
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

    XmlData                = @(
        @{ 
            Path       = 'D:\web.config'
            Ensure     = 'Present'
            XPath      = '/configuration/appSettings/Test1/Test2'
            Attributes = @{ TestValue1 = '1234' }
        }
    )

    NetworkIpConfiguration = @{
        IpAddress      = '10.0.0.1'
        Prefix         = 8
        Gateway        = '10.0.0.254'
        DnsServer      = '10.1.1.1', '10.1.1.2'
        InterfaceAlias = 'Ethernet'
        DisableNetbios = $true
    }   
    
    Network = @{
        NetworkZone = 1
        MtuSize = 1360
    }
}