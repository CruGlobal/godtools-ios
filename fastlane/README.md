fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios run_tests
```
fastlane ios run_tests
```
Runs all the tests - can take skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out. e.g. `bundle exec fastlane run_tests skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env test` (path must be relative to this project's main Fastfile)
### ios beta
```
fastlane ios beta
```
Creates a beta build - can take skip_tests, skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out. e.g. `bundle exec fastlane beta skip_tests:true skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env beta` (path must be relative to this project's main Fastfile)
### ios production
```
fastlane ios production
```
Deploy a new version to the App Store - can take skip_tests, skip_install_dependencies and setup_fastfile_path to improve speed if you have the setup Fastfile already checked out. e.g. `bundle exec fastlane production skip_tests:true skip_install_dependencies:true setup_fastfile_path:/path/to/common/Fastfile --env production` (path must be relative to this project's main Fastfile)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
