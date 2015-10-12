![PHG Icon](http://performancehorizon.com/img/logo-on-white.svg)

# Measurement Kit iOS SDK
#### Overview

Measurement Kit facilitates install and event tracking from within your app, as part of Performance Horizon's performance marketing service.  Simply add the SDK to your app, and you can begin to track a wide variety of actions with  Perfomance Horizon's tracking API.

### Installation

There are a number of options for integrating the iOS SDK into your project.  The preferred method is via Cocoapods (see <https://cocoapods.org/>).

#### CocoaPods

To install, add the following lines to your Podfile:

	pod 'PHNMeasurementKit', '~> 0.3.0' 

Then use the pod install command to download and install the library in your Xcode project.

#### Library

The static library libPHNMeasurementKit-pod.a and it’s associated umbrella header PHNMeasurementKit.h can also be directly imported into an Xcode project.  The library can be obtained by cloning the mobile tracking repository: <https://github.com/PerformanceHorizonGroup/measurementkit-cocoapod.git>

### Configuration

####Prerequisites

You'll need to be set up as a advertiser within Performance Horizon's affiliate tracking platform, with a campaign prepared.  Please contact support for any further guidance.

#### Initialise MeasurementKit

Whether you're tracking installs, other events,  or deep links, you'll need to initialise the SDK with your advertiser ID, and the campaign ID you'll be using for your mobile tracking links.

Import `<PHNMeasurementKit/PHNMeasurementService.h>` into your `AppDelegate.m`, and add the following

	#import <PHNMeasurementKit/PHNMeasurementService.h>

	- (void)applicationDidBecomeActive:(UIApplication *)application
	{

		NSString* phg_advertiser_id = @"advertiser_id";
		NSString* phg_campaign_id = @"campaign_to_be_tracked";

		[[PHNMeasurementService sharedInstance] startSessionWithAdvertiserID:phg_advertiser_id andCampaignID:phg_campaign_id];

	}

You will receive your unique PHG Advertiser ID and Campaign ID when you are registered within the Performance Horizon platform. It is important to note that an Advertiser account can have multiple Campaigns (apps).

#### Initialise from Deep link

The mobile tracking API appends a mobile tracking identifer to deep links (urls from from the app's scheme or universal links).  If you're using deep links in your app, add the following to method to  `application:openURL:options:` in your application delegate.

	- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
	{
	    // if you're processing the URI for routing in this method
	    // and you'd prefer the mobile tracking API additions removed,
	    // the output of this method is the original URI.

	    NSURL* originaluri = [[PHNMeasurementService sharedInstance] processDeepLinkWithURL:url];

	    //some routing, handling, etc....

	    return YES;
	}

###Tracking Events

#### MeasurementService instance

A static instance of the measurement service is provided for convenience.

	[PHNMeasurementService sharedInstance];

####Tracking Events
You can use events to track a variety of actions within your app.  Events are represented as conversions inside the affiliate interface.

#####Event
The most basic form of event has no value associated with it.  (Perhaps an in-app action on which you're not looking to reward affiliates.)

The `category` parameter is used to set the `product` conversions.

	PHNEvent* event = [[PHNMeasurementService sharedInstance] trackEvent:[PHNEvent eventWithCategory:@"registration-initiated"]];

#####Sales
If an event has a value you'd like to track, sales can be associated with an event as follows.

The `currency` parameter is a ISO 4217 currency code.  (eg, USD, GBP)


	//an example event with a single sale attached.	
	PHNEvent *registration = [PHNEvent eventWithSale:[PHNSale saleWithCategory:@"registration-complete" andValue:@(0.1)] ofCurrency:@"USD"];
    [[PHNMeasurementService sharedInstance] trackEvent:registration];

    //now one with several.....
    PHNEvent *purchases = [PHNEvent eventWithSales:@[[PHNSale saleWithCategory:@"premium-upgrade" andValue:@(0.1)], [PHNSale saleWithCategory:@"song-purchase" value:@(3.2) sku:@"biffyclyro-12" andQuantity:1]] ofCurrency:@"USD"];
    [[PHNMeasurementService sharedInstance] trackEvent:purchases];

`sku` and `quantity` are optional sales parameters.

###Performance

The SDK is designed to minimize the impact it has on it's parent app.  All operations are conducted on a low-priority background queue.  Setup is a single HTTP call, and if the install or deep link wasn't driven by an affilate, no further calls to the tracking API will be made. Events are cached to disk if there's no internet connection available.

