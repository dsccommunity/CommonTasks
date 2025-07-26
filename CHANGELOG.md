# Changelog for CommonTasks

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- AddsDomainController:
  - Add UnprotectFromAccidentalDeletion to allow dc promote if an existing AD
    computer account is protected
  - AllowPasswordReplication and DenyPasswordReplication Variables for RODCs
- AzureConnectedMachine:
  - Composite to install and configure the Azure Connected Machine Agent
- DhcpServerAuthorization:
  - new resource to authorize DHCP server in AD
- FailoverCluster:
  - add Networks support
  - add installation of required Windows Features
  - update documentation
- HyperVReplica
  - new resource to configure replication of Hyper-V virtual machines
- HyperVState
  - new resource to control state parameters of Hyper-V virtual machines
- RenameNetworkAdapters
  - Add composite to rename network adapters
  - Add documentation
- RemoteDesktopServers
  - new composite to add a number of servers to a RDS deployment
- DnsSuffixes
  - new resource to configure connection-specific DNS suffixes
- DfsReplicationGroupMembers
  - new resource to configure DFSR group members
- DfsReplicationGroupMemberships
  - new resource to configure DFSR group memberships
- DfsReplicationGroupConnections
  - new resource to configure DFSR replication connections

### Changed

- Fixed Typo in AddsDomainController documentation
- DHCPServer:
  - fix EnableSecurityGroups if resource is not running on a domain controller
- HyperV:
  - remove unused code after migration to HyperVDsc
- Pipeline
  - Updated to latest Sampler files and update an vmImage reference to `ubuntu-latest`
- `WindowsOptionalFeatures` and `WindowsFeatures` are using the DSC resource in
  `xPSDesiredStateConfiguration` now.
- `CertificateRequests` supports multiple certificates with the same issuer and
  subject by making friendlyName a mandatory (key) parameter.
- Updated versions of `SqlServerDsc` and `xRemoteDesktopSessionHost`.
- Updated build scripts to the latest version of Sampler.
- Updated dependency versions:
  - `JeaDsc` to `4.0.0-preview0005`.
  - `SqlServerDsc` to `17.1.0`.
  - `DscBuildHelpers` to `0.3.0-preview0003`.
- Updated test data for `SqlScriptQueries` according to new requirements.
- Updated the following resources according to new `DscBuildHelpers` version.
  - `WebApplication`
  - `Websites`
  - `HyperV`
  - `ConfigurationManagerConfiguration`

### Fixed

- Fixed bugs in 'DscTagging' and added parameter 'BuildNumber'.
- Fixed gitversion task in the pipeline.

### Removed

- AzureConnectedMachine:
  - Module has been removed from PSGallery

## [0.9.0] - 2023-02-08

### Added

- `PowershellExecutionPolicies` Composite for managing Powershell execution policies.
- `VSTSAgents` Composite for installing the Azure DevOps agents.
- `Robocopies` Composite for leveraging the Robocopy command.
- `VirtualMemoryFiles` Composite for adjusting the system page file via the resource `VirtualMemory` from the `ComputerManagementDsc` Module.
- `SharePointSetup` Composite for installing the SharePoint Prerequisits, Setup and optionally Language Packs.
- `AddsWaitForDomains` Composite for making sure a domain is reachable before going further.
- `CertificateExports` is used to export a certificate from the Windows certificate store.
- `AddsTrusts` Composite for establishing Forest trusts with more configuration options than using AddsDomain-property DomainTrusts.
- `FilesAndFolder` Add property to embed binary files into MOF.
- `SmbShares`  Add check and remove of duplicates from access properties in MOF.
- Complete YAML documentation
- `FileContents` Composite for managing file content.
- `RemoteDesktopDeployment` Composite to configure a remote desktop deployment
- `RemoteDesktopCollections` Composite to configure RD session collections, including their settings
- `RemoteDesktopLicensing` Composite to configure RD License server and license mode
- `ScomComponents` Composite to install SCOM components
- `ScomManagementPacks` Composite to import SCOM management packs from file or via inline XML
- `ScomSettings` Composite to set all available SCOM settings
- `CertificateRequest` Composite to request certificates from a certificate authority, includes automatic wait for ADCS to become available
- `ConfigurationManagerDistributionGroup` Composite to configure one or more distribution point groups
- `SQLAgentAlerts` Composite to configure one or more SQL Server Agent Alert on a SQL Server/Instance
- `SQLAgentOperators` Composite to configure one or more SQL Server Agent Operator on a SQL Server/Instance
- `SQLDatabaseMailSetups` Composite to configure one or more Database Mail Accounts/Profiles on a SQL Server/Instance
- `SQLScriptQueries` Composite to run one or more SQL Scripts against a SQL Server/Instance
- `RemoteDesktopCertificates` Composite to import Remote Desktop Certificates. Ideally combined with CertificateRequests and CertificateExports composites.
- `RemoteDesktopHAMode` Composite to configure High Availability mode on a RDS connection broker.

### Changed

- Changed the build pipeline to Sampler.
  - Debugging Sampler migration:
    - Added 'Sampler.GitHubTasks'.
    - Moved DSCResources for faster build.
    - Removed dependencies for faster build.
- Fixed badges.
- Added back configurations and dependencies.
- Fixing issue with Cluster when only NodeMajority is used.
  - Fixed the fix: Quorum is not required in some SQL Always-On scenarios which did not work after the fix.
- Add new resource LocalUsers.
- Make DscLcmController independent from the DscDiagnostics resource.
- Add optional attributes to DscTagging resource.
- Update documentation.
- Applied HQRM standards.
- Fixing issue with AddsOrgUnitsAndGroups when OUs contain other non-word characters.
- Added MmaAgent to configure Microsoft Monitoring Agent.
- Added AddsServicePrincipalNames to configure SPNs.
- Disabling RebootNodeIfNeeded when LCM is on Monitor mode.
- Made 'WaitForClusterRetryIntervalSec' and 'WaitForClusterRetryCount' configurable in Cluster config.
- Added new configuration 'WebConfigPropertyCollections'.
- Fixed an issue with duplicate resource identifiers in 'WebConfigProperties'.
- Changed parameter 'Name' to 'Names' in 'WindowsFeatures' and 'WindowsOptionalFeatures' resources according to coding convention.
- Made the Office Online Server resources actually work and redesigned them.
  - Added 'OfficeOnlineServerMachineConfig' configuration.
- WindowsFeatures configuration does not longer install all sub features. If needed, use prefix '*'.
- Changed dependencies in 'OfficeOnlineServerSetup'.
- Added CertificateImports to import certificates.
- Added parameter 'CheckPrerequisites' to 'WindowsEventForwarding' resource.
- Fixed issue with names containing special characters in 'LocalUsers' and 'LocalGroups' resources.
- Fixed issue with quotation marks in 'SqlServer' resource.
- Fixed issue with inter-configuration DependsOn by removing DependsOn inside configurations
- Added remote desktop control to 'ComputerSettings'.
- Fixed an issue with DscLcmController, the RebootNodeIfNeeded property is not.
set to false before the first execution of maintenance window.
- Fixed issue with DscLcmController, The RebootNodeIfNeeded property is not
set to true when the LCM is already in ApplyAndAutoCorrect mode.
- Fixed GitVersion depreciated version in azurepipeline.
- Fixed issue #156, switch plublish task to 'unbuntu-latest' vmimage.
- WindowsEventForwarding - replace localized system user names by SID to avoid problems on none english Windows systems.
- Documentation update.
- Removed DependsOn in ComputerSettings to ensure cross-configuration dependencies.
- Migration of tests to Pester 5.
- Added support for CimInstance parameters.
- Fixed issue with Cluster composite ignoring the IgnoreNetwork parameter.
- Fix #172 - RegistryPolicies: Error when Key or ValueName parameters contain bracket "()".
- ConfigurationManagerDeployment updated to allow Windows feature installation.
  - InstallWindowsFeatures could create duplicate resource issues if WindowsFeatures composite is used as well.
- ConfigurationManagerDeployment now has configurable Product Key.
- Made reading binary files in FilesAndFolders and CertificateImports more robust.
- Updated to latest version of 'PackageManagement' to fix module discovery error.
- WindowsServices: fix support of absent services (Ensure: Absent)
- HyperV: fix support of absent switches and VMs (Ensure: Absent)
- Changing to `windows-latest` for all pipeline jobs.
- Upgrade the following DSC resources to latest stable version:
  - NetworkingDsc
  - xWebAdministration ==> WebAdministrationDsc
  - ActiveDirectoryDsc
  - xDhcpServer
  - xFailoverCluster
  - SqlServerDsc
  - xHyper-V
  - VSTSAgent
  - xHyper-V ==> HyperVDsc
- Refactoring of SqlPermissions after upgrade of SqlServerDsc to 16.0.0
- WindowsFeatures: Include support for more elaborate lists of features, giving
  more control.
- Added task `FixEncoding` for being able to run the build on Windows PowerShell
  due to an encoding issue with the psd1 file
- Add missing documentation
- Added Read-Only Domaincontroller Variable to AddsDomainController
- WindowsFeatures: Include support for more elaborate lists of features, giving more control
- Breaking Change: Cluster renamed to FailoverCluster, since FailoverClusterDsc provides Cluster resource
  which is in conflict with the Cluster composite
