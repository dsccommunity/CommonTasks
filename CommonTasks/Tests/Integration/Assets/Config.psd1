@{
    AllNodes                 = @(
        @{
            NodeName                    = 'localhost_WindowsServices'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName                    = 'localhost_ChocolateyPackages'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName    = 'localhost_DscTagging'
            Environment = 'Dev'
        }
        @{
            NodeName                    = 'localhost_AdSitesSubnets'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName                    = 'localhost_DfsNamespace'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName                    = 'localhost_Domain'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName                    = 'localhost_DomainUsers'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
        }
        @{
            NodeName                    = 'localhost_OrgUnitsAndGroups'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            Environment                 = 'Dev'
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
            },
            @{
                DestinationPath = 'C:\TestShare'
                Ensure          = 'Present'
                Force           = $true
                Type            = 'Directory'
                ShareName       = 'ItsAShare'
            }
        )
    }
    AdSitesSubnets           = @{
        Sites   = @(
            @{
                Name                       = 'Sparta'
                RenameDefaultFirstSiteName = $true
            }
            @{
                Name = 'Site1'
            }
        )
        Subnets = @(
            @{
                Name     = '10.0.0.0/24'
                Site     = 'Sparta'
                Location = 'Sparta'
            }
        )
    }
    DfsNamespaces            = @{
        NamespaceConfig = @(
            @{
                Sharename = 'ADMINSHARE'
                Targets   = @('DscFile01', 'DscFile02')
            }
        )
    }
    Domain                   = @{
        DomainFqdn          = 'contoso.com'
        DomainName          = 'contoso'
        DomainDN            = 'DC=contoso,DC=com'
        DomainJoinAccount   = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
        DomainAdministrator = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
        SafeModePassword    = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
        DomainTrust         = @(
            @{
                Fqdn       = 'northwindtraders.com'
                Name       = 'northwindtraders'
                Credential = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
            }
        )
    }
    DomainUsers              = @{
        Users = @(
            @{
                UserName = 'test1'
                Password = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
            }
            @{
                UserName = 'test2'
                Password = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
            }
        )
    }
    IpConfiguration          = @{
        Adapter = @(
            @{
                MacAddress       = '00-17-FB-00-00-0A'
                NewName          = '1GB1_MGMT'
                IPAddress        = '10.0.0.33/23'
                AddressFamily    = 'IPv4'
                GatewayAddress   = '1.2.3.4'
                DnsServerAddress = @(
                    '1.2.3.4'
                    '2.3.4.5'
                )
                DisableIpv6      = $true
            }
            @{
                MacAddress    = '00-17-FB-00-00-0B'
                NewName       = 'STORAGE'
                IPAddress     = '10.2.0.33/24'
                AddressFamily = 'IPv4'
                DisableIpv6   = $true
            }
        )
    }

    OrgUnitsAndGroups        = @{
        Items  = @(
            @{
                Name    = 'Admin'
                Path    = 'DC=contoso,DC=com'
                ChildOu = @(
                    @{Name = 'Groups' }
                )
            }
        )
        Groups = @(
            @{
                GroupName  = 'App_123_Read'
                Path       = 'OU=Groups,OU=Admin'
                GroupScope = 'DomainLocal'
            }
        )
    }
    
    Wds                      = @{
        RemInstPath = 'C:\RemInst'
        RunAsUser   = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
        ScopeStart  = '2.1.32.1'
        ScopeEnd    = '2.1.33.254'
        ScopeId     = '2.1.32.0'
        SubnetMask  = '255.255.254.0'
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
        MaintenanceWindowMode       = 'AutoCorrect'
        MonitorInterval             = '02:00:00'
        AutoCorrectInterval         = '00:15:00'
        AutoCorrectIntervalOverride = $false
        RefreshInterval             = '04:00:00'
        RefreshIntervalOverride     = $false
        ControllerInterval          = '00:15:00'
        MaintenanceWindowOverride   = $false
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

    ChocolateyPackages       = @{
        Packages = @(
            @{
                Name              = 'notepadplusplus'
                Ensure            = 'Present'
                Version           = '1.0'
                ChocolateyOptions = @{ Source = 'SomeFeed' }
                Credential        = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
            },
            @{
                Name              = 'winrar'
                Ensure            = 'Present'
                Version           = '1.0'
                ChocolateyOptions = @{ Source = 'SomeFeed' }
                Credential        = (New-Object pscredential('contoso\test1', ('Password1' | ConvertTo-SecureString -AsPlainText -Force)))
            }
        )
    }

    ComputerSettings         = @{
        TimeZone    = 'Fiji Standard Time'
        Name        = 'TestServer'
        Description = 'This is a test server'
    }

    FirewallProfiles         = @{
        Profile = @(
            @{
                Name                    = 'Private'
                Enabled                 = 'True'
                DefaultInboundAction    = 'Block'
                DefaultOutboundAction   = 'Allow'
                AllowInboundRules       = 'True'
                AllowLocalFirewallRules = 'False'
            }
        )
    }

    FirewallRules            = @{
        Rules = @(
            @{
                Name        = 'Any-AnyTest'
                DisplayName = 'Any-Any Test'
                Enabled     = 'True'
                Description = 'Allow All Inbound Trafic'
                Direction   = 'Inbound'
                Profile     = 'Any'
                Action      = 'Allow'
                LocalPort   = 'Any'
                RemotePort  = 'Any'
                Protocol    = 'Any'
            }
        )
    }

}


