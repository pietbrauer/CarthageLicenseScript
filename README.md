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

```swift
./PATH_TO_YOUR_SCRIPT/fetch_licenses.swift Cartfile.resolved  OUTPUT_DIR
```

It takes 2 simple arguments:

|Argument|Explanation|
|:---|:---|
|Cartfile.resolved|Path to your Cartfile.resolved|
|OUTPUT_DIR|Path to the directory you want the Licenses.plist saved to|
