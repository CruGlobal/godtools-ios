# GodTools 3.1.X and below

This project contains all the code necessary to build and version of GodTools (and its offshoots: kgp and statisfied) up to 3.1.X

We're an open source project and always looking for more developers to help us expand GodTools features.  Contact support@godtoolsapp.com to get involved.

http://godtoolsapp.com

## Getting Started

### Requirements

* Cocoapods - http://cocoapods.org/

### Setup

Copy the example configuration files to active configuration files:

```bash
$ cp iPhone/Snuffy/Classes/Analytics/config.sample.plist iPhone/Snuffy/Classes/Analytics/config.plist
$ open iPhone/Snuffy/Classes/Analytics/config.plist
```
Fill in the blanks with the API keys you have been given. Ask a team member if you don't yet have these values.

### Install Gems

```bash
$ pod install
```

### Opening

```bash
$ open Snuffy.xcworkspace
```
To run it, select the godtools target and hit the play button in xcode's ribbon.

## License

The GodTools code is released under the MIT license:  http://www.opensource.org/licenses/MIT

Note: DO NOT use the images in this project without permission. Some of them are licensed to Cru only and can not be used by other people or organizations.
