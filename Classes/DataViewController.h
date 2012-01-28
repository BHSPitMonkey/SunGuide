//
//  DataViewController.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataView.h"
#import "SunGuideAppDelegate.h"
#import "sunriset.h"
#import "Shortcuts.h"
#import "NSObject+SolarPos.h"

@interface DataViewController : UIViewController {

	IBOutlet UILabel * location_name;		// Tells you which location you're using
	
	IBOutlet UILabel * information_name;	// Tells you which data set you're seeing
	
	IBOutlet UILabel * rise_title_label;	// Second column title
	IBOutlet UILabel * set_title_label;	// Third column title

	IBOutlet UILabel * column1label[6];
	IBOutlet UILabel * day_1_name_label;	// First column
	IBOutlet UILabel * day_2_name_label;
	IBOutlet UILabel * day_3_name_label;
	IBOutlet UILabel * day_4_name_label;
	IBOutlet UILabel * day_5_name_label;
	IBOutlet UILabel * day_6_name_label;

	IBOutlet UILabel * column2label[6];
	IBOutlet UILabel * day_1_rise_label;	// Second column
	IBOutlet UILabel * day_2_rise_label;
	IBOutlet UILabel * day_3_rise_label;
	IBOutlet UILabel * day_4_rise_label;
	IBOutlet UILabel * day_5_rise_label;
	IBOutlet UILabel * day_6_rise_label;
	
	IBOutlet UILabel * column3label[6];
	IBOutlet UILabel * day_1_set_label;		// Third column
	IBOutlet UILabel * day_2_set_label;
	IBOutlet UILabel * day_3_set_label;
	IBOutlet UILabel * day_4_set_label;
	IBOutlet UILabel * day_5_set_label;
	IBOutlet UILabel * day_6_set_label;
	
	IBOutlet UILabel * status_label;		// Label at the bottom
	
	int pageNumber;		// This is how we know which page we are.
	
	NSDateFormatter * dayFormat;	// Format for presenting a day of the week ("Monday")
	NSDateFormatter * timeFormat;	// Format for presenting a time ("6:30 PM")
	NSDateFormatter * zoneFormat;	// Format for presenting the time zone ("CST")
	
	NSCalendar * gregorian;			// Gregorian calendar object
	NSTimeZone * timezone;			// Stores the current NSTimeZone
	
	//double lon;
	//double lat;
}

- (id)initWithPageNumber:(int)page;
- (IBAction)populateWithData;
- (void)populateWithDataForLongitude:(double)lon forLatitude:(double)lat;
- (IBAction)callToggleView;
@end
