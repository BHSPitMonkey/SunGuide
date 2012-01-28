//
//  SunGuideAppDelegate.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SunGuideAppDelegate.h"
#import "LocationViewController.h"
#import "OfflineLocationViewController.h"
#import "MainViewController.h"
#import "Reachability.h"

@implementation SunGuideAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize currentCoordinate;

- (void)dealloc {

	[locationController release];
	[rootViewController release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	locationController = [[MyCLController alloc] init];
	[locationController.locationManager startUpdatingLocation];

	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];

	// Set default UserDefaults if needed
	if ([UD boolForKey:SETUP_DONE] == NO) {
		NSLog(@"Initial location setup needs to be done.");
		[UD setDouble:37.317206 forKey:PREF_LATITUDE];
		[UD setDouble:-122.044029 forKey:PREF_LONGITUDE];
		[UD setDouble:10 forKey:MAP_LATITUDE_SPAN];
		[UD setDouble:10 forKey:MAP_LONGITUDE_SPAN];
		[self showLocationPicker];
	}
}

- (void)setCurrentCoordinateWithLatitude:(double)latitude andLongitude:(double)longitude {
	
	// Store the new position
	CLLocationCoordinate2D pos = {latitude, longitude};
	currentCoordinateData = pos;
	currentCoordinate = &currentCoordinateData;
	
	// Repopulate the data views, if location services are desired
	if ([UD boolForKey:USE_LOCATION] == YES)
		[rootViewController.mainViewController repopulateAllDataViews];
	
	// Refresh the Flipside view
	[rootViewController.flipsideViewController viewDidAppear:NO];
}

#pragma mark Location Picker Methods

// Show the Preferred Location picker
- (void)showLocationPicker {
	
	// Make the controller
	UIViewController * lvc;	
	if ([[Reachability sharedReachability] isHostReachable:@"google.com"])
		lvc = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
	else
		lvc = [[OfflineLocationViewController alloc] initWithNibName:nil bundle:nil];

	lvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	// Show the controller
	if (lvc != nil) {
		[rootViewController presentModalViewController:lvc animated:YES];
		[lvc release];
	}
}

// Dismiss the picker controller
- (void)dismissLocationPicker {
	
	// Refresh the data views
	[rootViewController.mainViewController repopulateAllDataViews];
	
	// Refresh the underlying Settings view/table
	[rootViewController.flipsideViewController viewDidAppear:NO];
	
	// Dismiss the modal controller
	[rootViewController dismissModalViewControllerAnimated:YES];
}

@end


