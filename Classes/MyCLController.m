//
//  MyCLController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyCLController.h"
#import "SunGuideAppDelegate.h"
#import "MainViewController.h"


@implementation MyCLController

@synthesize locationManager;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self;	// send location updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"Location changed to: ", [newLocation description]);

	// Change the Current Lat/Long variables in the AppDelegate
	[AD setCurrentCoordinateWithLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSLog(@"Location error: ", [error description]);
}

- (void)dealloc {
	[self.locationManager release];
	[super dealloc];
}

@end
