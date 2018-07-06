# Shared Dsc Configurations
[![Build status](https://ci.appveyor.com/api/projects/status/63pvwjs2waifgty8?svg=true)](https://ci.appveyor.com/project/gaelcolas/shareddscconfig)

This project is intended to suggest a new structure for sharing DSC Configuration, taking most of the ideas from [Michael Greene](https://github.com/mgreenegit/) in [the dscconfigurations repo](https://github.com/powershell/dscconfigurations).

## Value Proposition

The value we're looking to provide, is to `do something similar to DSC Resource for System or Service Configurations.`

We want to lower the bar of bootstrapping infrastructure with DSC, by re-using configurations of system or services people have built and shared.

Using Geoffrey Moore's value proposition model:

>For __People starting with Configuration Management__
>
>Who __need to deploy systems or services quickly__
>
>Our __configuration sharing guidelines__ is __a re-usable build process for DSC configurations__
>
>That __transforms Configuration into re-usable and composable DSC Composite Resources__



## Intent

<div style="align:right"><img src ="./docs/media/FileTree.png" / align='right'>
The intent is to:

- simplify the way to consume a shared configuration
- Allow direct re-use in new environment (no copy-paste/modification of DSC Config or data)
- reduce the _cost_ of sharing, by automating the scaffolding (plaster), testing (pester, PSSA, Integration tests), building (Composite Resource), Publishing (PSGallery)
- ensuring high quality, by allowing the use of a testing harness fit for TDD
- Allow Build tools, tasks and scripts to be more standardized and re-usable
- ensure quick and simple iterations during the development process

To achieve the intent, we should:
- provide a familiar scaffolding structure similar to PowerShell modules
- create a model that can be self contained (or bootstrap itself with minimum dependencies)
- Be CI/CD tool independant
- Declare Dependencies in Module Manifest for Pulling requirements from a gallery
- Embed default Configuration Data alongside configs
- Provides guidelines, conventions and design patterns (i.e. re-using Configuration Data)
- Support test-kitchen model (i.e. module injection, Test Suite)
- De-Clutter module to upload by not including unecessary fiels (i.e. Removing .Build files)

## Ideas to discuss

Before going further it's good to have an understanding of [how the DSC resource and configurations works](./docs/ResourceAndConfigs.md), and the [different method of composition](./docs/composition.md) they offers.

Below are ideas I think worth discussing and suggestions of implementation. Please raise issues to discuss them.

### Repository Structure

```
SHAREDDSCCONFIG
│   .build.ps1
│   .gitignore
│   .kitchen.yml
│   appveyor.yml
│   LICENSE
│   PSDepend.build.psd1
│   PSDepend.resources.psd1
│   README.md
│
├───.build
│       README.md
│
├───BuildOutput
│       README.md
│
├───docs
│   └───media
│
├───DSC_Resources
│       README.md
│
└───SharedDscConfig
    │   SharedDscConfig.psd1
    │
    ├───DscResources
    │   └───Shared1
    │       │   Shared1.psd1
    │       │   Shared1.schema.psm1
    │       │
    │       ├───ConfigData
    │       │   │   Datum.yml
    │       │   │
    │       │   └───common
    │       │           SharedDscConfig.psd1
    │       │
    │       └───Diagnostics
    │           ├───Comprehensive
    │           └───Simple
    │                   SharedDscConfig.tests.ps1
    │
    └───examples
        │   Default.ps1
        │
        └───ConfigData
            │   Datum.yml
            │
            └───AllNodes
                    localhost.yml
```
The Shared Configuration should be self contained, but will require files for building/testing or development.
The repository will hence need some project files on top of the files required for functionality.

Adopting the 2 layers structure like so:
```
+-- ConfigurationName\
    +-- ConfigurationName\
```
Allows to place Project files like build, CI configs and so on at the top level, and everything under the second level are the files that need to be shared and will be uploaded to the PSGallery.


Within that second layer, the Configuration looks like a standard module with some specificities.

### Configuration Data

This is tricky to get right.

The configuration data, IMO, should be managed in an 'override-only' way to preserve the cattle vs pet case. That is: 
- everything is standard (the standard/best practice data being shared alongside the configuration script), 
- but can be overriden in specific cases when required (overriding a domain name, certificate and so on).

This cannot be done out of the box (without tooling), but it's possible using custom scripts or module, as I intend to with my [Datum](https://github.com/gaelcolas/datum) module.

The challenge is then to manage the config data for a shared config in a way compatible with using a Configuration Data management module or function.


I see two possible approach:
- Conform with the most documented approach which is to cram properties under statically define values in hashtable: i.e. `$Node.Role.property` or `$AllNodes.Role.Property`, but that is very hacky or does not scale
- Introduce the less documented, more flexible way to resolve a property for the current Node via a function: i.e. `Resolve-DscProperty -Node $Node -PropertyPath 'Role\Property'`

The second one is more flexible (anyone can create their custom one), but probably needs some time and a lot of communication before taking precedence over the static way.

We could [provide a standard, simple function](./SharedDscConfig/examples/scripts/Resolve-DscConfigurationData.ps1) to resolve the static properties when creating Shareable configurations, where the logic can be overriden where consuming that shared configuration.

```PowerShell
function Resolve-DscConfigurationData {
    Param(
        [hashtable]$Node,
        [string]$PropertyPath,
        [AllowNull()]
        $Default
    )

    $paths = $PropertyPath -split '\\'
    $CurrentValue = $Node
    foreach ($path in $Paths) {
        $CurrentValue = $CurrentValue.($path)
    }

    if ($null -eq $CurrentValue -and !$PSBoundParameters.ContainsKey('Default')) {
        Throw 'Property returned $null but no default specified.'
    }
    elseif ($CurrentValue) {
        Write-Output $CurrentValue
    }
    else {
        Write-Output $Default
    }
}
Set-Alias -Name ConfigData -value Resolve-DscConfigurationData
Set-Alias -Name DscProperty -value Resolve-DscConfigurationData
```

This Allows to resolve static data so that: 
```PowerShell
DscProperty -Node @{
        NodeName='localhost';
        a=@{
            b=122
        }
    } -PropertyPath 'a\b'
```
Resolves to `122`, but another implementation of Resolve-DscConfigurationData could do a database lookup in the company's CMDB for instance.

Doing so would allow to have functions to lookup for Configuration Data from the Shared Configuration, or from custom overrides.

### Root Tree
<div style="align:right"><img src ="./docs/media/rootTree.png" / align='right'>
The root of the tree would be similar to a module root tree where you have supporting files for, say, the CI/CD integration.

In this example, I'm illustrating the idea with:
- a .Build.ps1 that defines the build workflow by composing tasks (see [SampleModule](https://github.com/gaelcolas/SampleModule))
- a .build/ folder, which includes the minimum tasks to bootstrap + custom ones
- the .gitignore where folders like BuildOutput or kitchen specific files are added (`module/`)
- the [Dependencies.psd1](./Dependencies.psd1), so that the build process can use [PSDepend](https://github.com/RamblingCookieMonster/PSDepend/) to pull any prerequisites to build that project
- the test-kitchen configuration file (omitting the driver, so that it can be set on a global/local config based on the user's environment/platform)
- the appveyor configuration file (for appveyor CI integration)
- supporting files like License, Readme, media...


## Configuration Module Folder
<div style="align:right"><img src ="./docs/media/SharedConfigFolder.png" / align='right'>

Very similar to a PowerShell Module folder, the Shared configuration re-use the same principles and techniques.

The re-usable configuration itself is declared in the ps1, the metadata and dependencies in the psd1 to leverage all the goodies of module management, then we have some assets ordered in folders:
- ConfigurationData: the default/example configuration data, organised in test suite/scenarios
- Validation: the pester tests used to validate the configuration, per test suite/scenario
- the examples of re-using that shared configuration, per test suite/scenario
