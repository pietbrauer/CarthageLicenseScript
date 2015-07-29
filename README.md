# Download Licenses for Carthage

![Carthage Compatibility](https://img.shields.io/badge/Carthage-✔-f2a77e.svg?style=flat)
![Swift](https://img.shields.io/badge/Swift-1.2-orange.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)
![Platform](https://img.shields.io/badge/Platform-OS X-lightgrey.svg)
[![@pietbrauer](https://img.shields.io/badge/Contact-%40pietbrauer-blue.svg)](https://twitter.com/pietbrauer)

To display open source licenses for your dependencies it can be very cumbersome to download each dependency by hand.

CocoaPods does it automatically, but if you are using Carthage there is no such option.

You can simply add this script to your project (by downloading) or use it as a submodule or subtree.

## Usage

I won't recommend running it as a build phase, but rather checking the generated `.plist` into your project.

You can execute this script by running:

```bash
$ ./PATH_TO_YOUR_SCRIPT/fetch_licenses.swift Cartfile.resolved  OUTPUT_DIR
```

It takes 2 simple arguments:

|Argument|Explanation|
|:---|:---|
|Cartfile.resolved|Path to your Cartfile.resolved|
|OUTPUT_DIR|Path to the directory you want the Licenses.plist saved to|

### Example output

If everything goes well you will see something like:

```bash
$ ./fetch_licenses.swift ../Git2Go/Cartfile.resolved ../Git2Go/
Fetching licenses for Mantle/Mantle ...
Fetching licenses for nerdishbynature/OpenSSL ...
Fetching licenses for ReactiveCocoa/ReactiveCocoa ...
Fetching licenses for soffes/SSKeychain ...
Fetching licenses for nerdishbynature/ios-snapshot-test-case ...
Fetching licenses for libgit2/objective-git ...
Fetching licenses for nerdishbynature/ocmock ...
Fetching licenses for octokit/octokit.objc ...
Super awesome! Your licenses are at ../Git2Go/Licenses.plist 🍻
```
