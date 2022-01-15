# Changelog for CommonTasks

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Changed the build pipeline to Sampler.
  - Debugging Sampler migration:
    - Added 'Sampler.GitHubTasks'.
    - Moved DSCResources for faster build.
    - Removed dependencies for faster build.
- Fixed badges.
- Added back configurations and dependencies.
- Fixing issue with Cluster when only NodeMajority is used.
- Add new resource LocalUsers.
- Make DscLcmController independent from the DscDiagnostics resource.
- Add optional attributes to DscTagging resource.
- Update documentation.
- Applied HQRM standards.
- Fixing issue with AddsOrgUnitsAndGroups when OUs contain other non-word characters.
- Added MmaAgent to configure Microsoft Monitoring Agent.
- Added AddsServicePrincipalNames to configure SPNs.
