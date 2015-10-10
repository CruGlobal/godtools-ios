God Tools iOS
============

iOS app for GodTools. This version of the app is connected to the God Tools API https://github.com/CruGlobal/godtools-api and displays resources in the God Tools viewer https://github.com/CruGlobal/GTViewController

Learn more at http://godtoolsapp.com

We're an open source project and always looking for more developers to help us expand GodTools features.  Contact support@godtoolsapp.com to get involved.

Requirements
---
[Cocoapods](www.cocoapods.org)
```
gem install cocoapods
```

Setup
---
```
pod install
cp godtools/godtools-ios-api/config.sample.plist godtools/godtools-ios-api/config.plist
open godtools.xcworkspace
```
Navigate to godtools/godtools-ios-api/config.plist and enter in your API keys. Email support@godtoolsapp.com to request the official API keys if you are a part of the main development team.

Now you should be able to build and contribute normally.


Localization
---
To update or add to the translation efforts on this app read the [Localization documentation](https://github.com/CruGlobal/godtools-ios/wiki/Localization)

Testing
---
We used the standard XCTest framework that comes with xcode. You can run them via xcode's interface. However, we have limited tests atm. Help is very welcome.

Releasing
---
To release this app under Cru's distribution account please contact support@godtoolsapp.com. Otherwise follow Apple's instructions on distribution.

License
---
The GodTools code is released under the MIT license:  http://www.opensource.org/licenses/MIT

Note: DO NOT use the images in this project without permission. Some of them are licensed to Cru only and can not be used by other people or organizations.

