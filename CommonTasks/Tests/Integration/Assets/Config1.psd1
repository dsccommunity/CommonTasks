@{
    AllNodes                 = @(
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

    FilesAndFolders          = @{
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

    WindowsFeatures          = @{
        Name = 'XPS-Viewer', '-Web-Server'
    }

    RegistryValues           = @{
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

    SecurityBase             = @{
        SecurityLevel = 2
    }

    ConfigurationBase        = @{
        SystemType = 'Baseline'
    }

    WindowsServices          = @{
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

    XmlData                  = @(
        @{ 
            Path       = 'D:\web.config'
            Ensure     = 'Present'
            XPath      = '/configuration/appSettings/Test1/Test2'
            Attributes = @{ TestValue1 = '1234' }
        }
    )

    NetworkIpConfiguration   = @{
        IpAddress      = '10.0.0.1'
        Prefix         = 8
        Gateway        = '10.0.0.254'
        DnsServer      = '10.1.1.1', '10.1.1.2'
        InterfaceAlias = 'Ethernet'
        DisableNetbios = $true
    }   
    
    Network                  = @{
        NetworkZone = 1
        MtuSize     = 1360
    }

    DscLcmMaintenanceWindows = @{
        MaintenanceWindow = @(
            @{
                Mode      = 'Daily'
                Name      = 'MW-1'
                StartTime = '00:30:00'
                Timespan  = '02:00:00'
            }
            @{
                Mode      = 'Daily'
                Name      = 'MW-2'
                StartTime = '04:00:00'
                Timespan  = '01:00:00'
            }
        )
    }

    DscLcmController         = @{
        ConsistencyCheckInterval         = '02:00:00'
        ConsistencyCheckIntervalOverride = $false
        RefreshInterval                  = '04:00:00'
        RefreshIntervalOverride          = $false
        ControllerInterval               = '00:15:00'
        PostponeInterval                 = '168:00:00'
        MaintenanceWindowOverride        = $false
    }

    WebApplicationPools      = @{
        Items = @(
            @{
                Name = 'TestAppPool1'
            },
            @{
                Name = 'TestAppPool2'
            }
        )
    }

    WebApplications          = @{
        Items = @(
            @{
                Name         = 'TestApp1'
                PhysicalPath = 'C:\InetPub\WebApplications1'
                WebAppPool   = 'TestApp1'
                WebSite      = 'TestSite1'
            }
        )
    }

    WebSites                 = @{
        Items = @(
            @{
                Name            = 'TestSite1'
                ApplicationPool = 'TestAppPool1'
            }
        )
    }

    WebVirtualDirectories    = @{
        Items = @(
            @{
                Name           = 'VirtualDirectory1'
                PhysicalPath   = 'C:\InetPub\VirtualDirectory1'
                WebApplication = 'TestApp1'
                WebSite        = 'TestSite1'
            },
            @{
                Name           = 'VirtualDirectory2'
                PhysicalPath   = 'C:\InetPub\VirtualDirectory2'
                WebApplication = 'TestApp1'
                WebSite        = 'TestSite1'
            }
        )
    }

    SoftwarePackages         = @{
        Packages = @(
            @{
                Name      = 'Software One'
                Path      = '\\Server\Share\SoftwareOne\SoftwareOne.msi'
                ProductId = 'aa859ee6-4f64-439a-85c0-bc1207886cb6'
            },
            @{
                Name      = 'Software Two'
                Path      = '\\Server\Share\SoftwareOne\SoftwareTwo.msi'
                ProductId = '734f1912-01b1-4f50-8bba-9c3f8912ee8d'
            }
        )
    }
}
