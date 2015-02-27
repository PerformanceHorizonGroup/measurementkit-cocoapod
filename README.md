Installing PHG Mobile Tracking iOS SDK using CocoaPods
=======
Please note this SDK is undergoing pre-release testing at present.
=======

[CocoaPods: The Objective-C Library Manager](http://www.cocoapods.org) allows you to manage the library dependencies of your iOS Xcode project.
You can use CocoaPods to install PHG Mobile Tracking iOS SDK and required system frameworks.

## Steps to include PHG Mobile Tracking iOS SDK to your iOS Xcode project

### Install CocoaPods

If you have already installed CocoaPods then you can skip this step.
```
$ [sudo] gem install cocoapods
$ pod setup
```
### Install PHG MobileTracking pod

Once CocoaPods has been installed, you can include PHG Mobile Tracking iOS SDK to your project by adding a dependency entry to the Podfile in your project root directory.

```
platform :ios
pod 'PHGMobileTracking'
```

This sample shows a minimal Podfile that you can use to include PHG Mobile Tracking iOS SDK dependency to your project. You can include any other dependency as required by your project.

Now you can install the dependencies in your project:

```
$ pod install
```

Once you install a pod dependency in your project, make sure to always open the Xcode workspace instead of the project file when building your project:

```
$ open App.xcworkspace
```

Now you can import PHG Mobile Tracking in your source files:

```
#import <PHGMobileTrackingService.h>
```

At this point PHG Mobile Tracking iOS SDK is ready for use in your project.
