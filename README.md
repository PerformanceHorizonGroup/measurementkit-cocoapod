![PHG Icon](http://performancehorizon.com/img/logo-on-white.svg)

# PHG iOS SDK
#### Overview

The PHG SDK facilitates initital user registration and event logging from within your app. Simply download the SDK, add into your app, and you can begin to track a wide variety of actions to the PHG tracking API.

### Installation

There are a number of options for integrating the iOS SDK into your project.  The preferred method is via Cocoapods (see <https://cocoapods.org/>).

#### CocoaPods

To install, add the following lines to your Podfile:

	pod 'PHGMobileTracking', :git => ‘https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git'

Then use the pod install command to download and install the library in your Xcode project.

#### Library

The static library libPHGMobileTracking-pod.a and it’s associated header files, PHGMobileTrackingEvent, PHGMobileTrackingSale, and PHGMobileTrackingService can also be directly imported into an Xcode project.  The library can be obtained by cloning the mobile tracking repository: <https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git>

### Implementing
#### Configuration

Import `<PHGMobileTracking/PHGMobileTrackingService.h>` into your `AppDelegate.m`, and initialise.

	#import <PHGMobileTracking/PHGMobileTrackingService.h>
	
	- (void)applicationDidBecomeActive:(UIApplication *)application
	{ 
		//Apple Identifier for Advertisers (IFA) passthrough, enabling accurate tracking 
		[PHGMobileTrackingService trackingInstance].idfa = [[ASIdentifierManager 		   		sharedManager] advertisingIdentifier];
	
		[[PHGMobileTrackingService trackingInstance] 			  	initialiseTrackingWithAdvertiserID:@"phg_advertiser_id" 										     andCampaignID:@"phg_campaign_id"];
	}

You will receive your unique PHG Advertiser ID and Campaign ID when you are registered within the PHG platform. It is important to note that an Advertiser account can have multiple Campaigns (apps).

####Tracking Methods
The PHG SDK offers a generic event method to register dynamic actions, but there are also some pre-defined event types which can have specific report views associated with them in the PHG ExactView platform. These pre-defined events range from simple actions like installs and registrations, through to paid actions such as in-app purchases.

#####Registration
The registration call captures a user registering within the app. An optional `user_id` can be passed.

    PHGMobileTrackingEvent* event = [[PHGMobileTrackingEvent alloc] initWithEventTag:@"Registration"];
	[event addEventInformationWithKey:@"custref" andValue:@"user_id"];
	[[PHGMobileTrackingService trackingInstance] trackEvent:event];

####Event
Any action within an app, which involves a single event, can be captured using a dynamic `EventTag` identifier with an optional `currency`/`value` combination if there's a cost associated with the action, and this can also reference a unique transaction identifier `conversionref`.

	PHGMobileTrackingEvent* event = [[PHGMobileTrackingEvent alloc] initWithEventTag:@"Premium"];
	[[PHGMobileTrackingService trackingInstance] trackEvent:event];

	// Conversion information
	[event addEventInformationWithKey:@"currency"
	andValue:@"iso_3_letter_currency"];

	[event addEventInformationWithKey:@"value" andValue:@"decimal"];
	[event addEventInformationWithKey:@"conversionref" andValue:@“order_id"];

####Purchase
A purchase is an event which includes more than one item, for example a paid transaction which includes multiple items within the order. `currency` and `conversionref` is referenced in combination with an array of items, which must include a `category` to describe the type of item, and `value` which is the net cost of a single unit. These item level attributes can be accompanied with an optional `sku` value to reference the unique item code and `quantity` for calculating multiple instances of the same item.

	PHGMobileTrackingEvent* event = [[PHGMobileTrackingEvent alloc] initWithEventTag:@"Purchase"];
	[event addEventInformationWithKey:@"conversionref" andValue:@“order_id"];

	[event addSales: @[[PHGMobileTrackingSale saleWithCategory:@"album" value:@(9.99) sku:@"829983" andQuantity:1], [PHGMobileTrackingSale saleWithCategory:@"single" value:@(0.99) sku:@"973723" andQuantity:1]] ofCurrency:@"currency_iso_string"];
