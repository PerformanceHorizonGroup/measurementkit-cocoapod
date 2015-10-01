![PHG Icon](http://performancehorizon.com/img/logo-on-white.svg)

# Mobile Tracking iOS SDK
#### Overview

The PHG mobile tracking SDK facilitates install and event tracking from within your app.  Simply download the SDK, add into your app, and you can begin to track a wide variety of actions with PHG tracking API.

### Installation

There are a number of options for integrating the iOS SDK into your project.  The preferred method is via Cocoapods (see <https://cocoapods.org/>).

#### CocoaPods

To install, add the following lines to your Podfile:

	pod 'PHGMobileTracking', :git => ‘https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git'

Then use the pod install command to download and install the library in your Xcode project.

#### Library

The static library libPHGMobileTracking-pod.a and it’s associated umbrella header PHGMobileTracking.h can also be directly imported into an Xcode project.  The library can be obtained by cloning the mobile tracking repository: <https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git>

### Configuration

####Prerequisites

You'll need to be set up as a advertiser within Performance Horizon's affiliate tracking platform, with a campaign prepared.  Please see the Mobile Tracking API guide (link TBC), or contact support for instructions.

#### Initialise mobile tracking

Whether you're tracking installs or deep links, you'll need to initialise the mobile tracking SDK with your advertiser ID, and the campaign ID you'll be using for your mobile tracking links.

Import `<PHGMobileTracking/PHGMobileTrackingService.h>` into your `AppDelegate.m`, and add the following 

	#import <PHGMobileTracking/PHGMobileTrackingService.h>
	
	- (void)applicationDidBecomeActive:(UIApplication *)application
	{ 
	
		[[PHGMobileTrackingService trackingInstance] initialiseTrackingWithAdvertiserID:@"phg_advertiser_id" 										     andCampaignID:@"phg_campaign_id"];
	}

You will receive your unique PHG Advertiser ID and Campaign ID when you are registered within the Performance Horizon platform. It is important to note that an Advertiser account can have multiple Campaigns (apps).

#### Initialise from Deep link

The mobile tracking API appends a mobile tracking identifer to deep links (uris from from the app's scheme or universal links).  If you're using deep links in your app, add the following to method to  `application:openURL:options:` in your application delegate.

	- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
	{
	    // if you're processing the URI for routing in this method
	    // and you'd prefer the mobile tracking API additions removed,
	    // the output of this method is the original URI.
	    
	    NSURL* originaluri = [[PHGMobileTrackingService trackingInstance] processDeepLinkWithURL:url];
	    
	    //some routing, handling, etc....
	    
	    return YES;
	}
	
###Tracking Events
	
#### Mobile tracking instance

A static instance of the mobile tracking service is provided for convenience.

	[PHGMobileTrackingService getInstance];

####Tracking Events
You can use events to track a variety of actions within your app.  Events are represented as conversions inside the affiliate interface.

#####Event
The most basic form of event has no value associated with it.  (Perhaps an in-app action on which you're not looking to reward affiliates.)

The `category` parameter is used to set the `product` conversions.

	PHGMobileTrackingEvent* event = [[PHGMobileTrackingService trackingInstance] trackEvent:[PHGMobileTrackingEvent eventWithCategory:@"registration-initiated"]];    

#####Sales
If an event has a value you'd like to track, sales can be associated with an event as follows.

The `currency` parameter is a ISO 4217 currency code.  (eg, USD, GBP)

	
	//an example event with a single sale attached.	PHGMobileTrackingEvent *registration = [PHGMobileTrackingEvent eventWithSale:[PHGMobileTrackingSale saleWithCategory:@"registration-complete" andValue:@(0.1)] ofCurrency:@"USD"];    
    [[PHGMobileTrackingService trackingInstance] trackEvent:registration];
           
    //now one with several.....
    PHGMobileTrackingEvent *purchases = [PHGMobileTrackingEvent eventWithSales:@[[PHGMobileTrackingSale saleWithCategory:@"premium-upgrade" andValue:@(0.1)], [PHGMobileTrackingSale saleWithCategory:@"song-purchase" value:@(3.2) sku:@"biffyclyro-12" andQuantity:1]] ofCurrency:@"USD"];
	[[PHGMobileTrackingService trackingInstance] trackEvent:purchases];

`sku` and `quantity` are optional sales parameters.  

###Performance

The mobile tracking SDK is designed to minimize the impact it has on it's parent app.  All operations are conducted on a low-priority background queue.  Setup is a single HTTP call, and if the install or deep link wasn't driven by an affilate, no further calls to the mobile tracking API will be made. Events are cached to disk if there's no internet connection available.

