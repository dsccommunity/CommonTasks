# Changelog for CommonTasks

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `VirtualMemoryFiles` Composite for adjusting the system page file via the resource `VirtualMemory` from the `ComputerManagementDsc` Module.
- `SharePointSetup` Composite for installing the SharePoint Prerequisits, Setup and optionally Language Packs.
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
- Fixed an issue with DscLcmController, the RebootNodeIfNeeded property is not
set to false before the first execution of maintenance window.
