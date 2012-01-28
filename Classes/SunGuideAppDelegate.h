//
//  SunGuideAppDelegate.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DataViewController.h"
#import "MyCLController.h"

@class RootViewController;

@interface SunGuideAppDelegate : NSObject <UIApplicationDelegate, UIScrollViewDelegate> {
	IBOutlet UIWindow * window;
	RootViewController * rootViewController;
	
	MyCLController * locationController;
	CLLocationCoordinate2D * currentCoordinate;		// Set by CoreLocation delegate
	CLLocationCoordinate2D currentCoordinateData;

}

NSDate * days[6];

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet RootViewController * rootViewController;
@property (nonatomic) CLLocationCoordinate2D * currentCoordinate;

- (void)setCurrentCoordinateWithLatitude:(double)latitude andLongitude:(double)longitude;
- (void)showLocationPicker;
- (void)dismissLocationPicker;

@end

