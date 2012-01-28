//
//  DataViewController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataViewController.h"
#import "RootViewController.h"
#import "NSObject+SolarPos.h"

#define SECONDS_IN_A_DAY 86400

@implementation DataViewController

#pragma mark Initialization

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page
{
    self = [super initWithNibName:@"DataView" bundle:nil];
    if (self) {
        pageNumber = page;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
// This method populates the view with information, depending on the page number
- (void)viewDidLoad
{
	// Do some one-time date object setup. Initializes the array days[], containing NSDates for and the next 5 days.
	NSDate * today = [NSDate date];
	gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * todayComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:today];
	days[0] = [gregorian dateFromComponents:todayComponents];
	[days[0] retain];
	[gregorian autorelease];
	for (int i=1; i<6; i++)
	{
		days[i] = [days[0] dateByAddingTimeInterval:i*SECONDS_IN_A_DAY];
		[days[i] retain];
	}
	
	// Initialize the current NSTimeZone and save it for later. The other methods will want it!
	timezone = [gregorian timeZone];
	
	// Set up column 1 as an easy array.
	column1label[0]	= day_1_name_label;
	column1label[1]	= day_2_name_label;
	column1label[2]	= day_3_name_label;
	column1label[3]	= day_4_name_label;
	column1label[4]	= day_5_name_label;
	column1label[5]	= day_6_name_label;

	// Set up column 2 as an easy array.
	column2label[0]	= day_1_rise_label;
	column2label[1]	= day_2_rise_label;
	column2label[2]	= day_3_rise_label;
	column2label[3]	= day_4_rise_label;
	column2label[4]	= day_5_rise_label;
	column2label[5]	= day_6_rise_label;
	
	// Set up column 3 as an easy array.
	column3label[0]	= day_1_set_label;
	column3label[1]	= day_2_set_label;
	column3label[2]	= day_3_set_label;
	column3label[3]	= day_4_set_label;
	column3label[4]	= day_5_set_label;
	column3label[5]	= day_6_set_label;
	
	// Decide how days and times are displayed
	dayFormat = [[NSDateFormatter alloc] init];
	[dayFormat setDateFormat:@"EEEE"];
	
	timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setDateFormat:@"h:mm a"];
	
	zoneFormat = [[NSDateFormatter alloc] init];
	[zoneFormat setDateFormat:@"z"];

	// Initialize the first column's day labels
	for (int i=0; i<6; i++)
		column1label[i].text	= [dayFormat stringFromDate:days[i]];
	
	// Run the calculations, populate the view with information
	[self populateWithData];
	
    [super viewDidLoad];
}

// With no specific longitude/latitude passed, this method will decide the most appropriate location to go by
- (IBAction)populateWithData
{	
	// If there is a Current Location set, call populateWithData using that location	
	if (([AD currentCoordinate] != nil) && ([UD boolForKey:USE_LOCATION] == YES)) {
		[self populateWithDataForLongitude:[AD currentCoordinate]->longitude
							   forLatitude:[AD currentCoordinate]->latitude];
		location_name.text = @"For Current Location";
		location_name.textColor = [UIColor colorWithHue:223/360.0 saturation:0.43 brightness:1.0 alpha:1.0];
	}

	// Else call populateWithData using the Preferred Location
	else
	{
		[self populateWithDataForLongitude:[UD doubleForKey:PREF_LONGITUDE]
							   forLatitude:[UD doubleForKey:PREF_LATITUDE]];
		location_name.text = @"For Preferred Location";
		location_name.textColor = [UIColor whiteColor];
	}
}

// Populate the current dataview with data
- (void)populateWithDataForLongitude:(double)lon forLatitude:(double)lat
{
	// location_name.text = [NSString stringWithFormat:@"For %3.2f, %3.2f", lon, lat];

	// Place different data on each page
	switch (pageNumber)
	{
		// First page: Sun rise and set times
		case 0:
			information_name.text	= @"Solar Rise and Set";
			rise_title_label.text	= @"Sunrise";
			set_title_label.text	= @"Sunset";

			double rise_time, set_time;		// Will store the rise and set times

			// Populate columns 2 and 3 with sunrise/sunset times
			for (int i=0; i<6; i++)
			{
				rise_time = 0;
				set_time = 0;

				sun_rise_set(	[[[days[i] description] substringWithRange:NSMakeRange(0,4)] intValue],
								[[[days[i] description] substringWithRange:NSMakeRange(5,2)] intValue],
								[[[days[i] description] substringWithRange:NSMakeRange(8,2)] intValue],
								lon,
								lat,
								&rise_time,
								&set_time
							 );
				
				// Populate this row with the rise and set times, based on NSDate objects. Adjust them based on the timezone. (This also covers DST.)
				int tz_offset = [timezone secondsFromGMTForDate:days[i]];
				column2label[i].text	= [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(rise_time*3600.0)+tz_offset]];
				column3label[i].text	= [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(set_time*3600.0)+tz_offset]];
			}
			
			status_label.text = [NSString stringWithFormat:@"All times in %@", [zoneFormat stringFromDate:[NSDate date]]];
			break;

		// Second page: Civil twilight times
		case 1:
			information_name.text = @"Civil Twilight";
			rise_title_label.text = @"Start";
			set_title_label.text = @"End";
			
			double civ_start, civ_end;		// Will store the rise and set times
			
			// Populate columns 2 and 3 with sunrise/sunset times
			for (int i=0; i<6; i++)
			{
				rise_time = 0;
				set_time = 0;
				
				civil_twilight(	[[[days[i] description] substringWithRange:NSMakeRange(0,4)] intValue],
							   [[[days[i] description] substringWithRange:NSMakeRange(5,2)] intValue],
							   [[[days[i] description] substringWithRange:NSMakeRange(8,2)] intValue],
							   lon,
							   lat,
							   &civ_start,
							   &civ_end
							   );
				
				int tz_offset = [timezone secondsFromGMTForDate:days[i]];
				column2label[i].text = [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(civ_start*3600.0)+tz_offset]];
				column3label[i].text = [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(civ_end*3600.0)+tz_offset]];
			}
			
			status_label.text = [NSString stringWithFormat:@"All times in %@", [zoneFormat stringFromDate:[NSDate date]]];
			
			break;

		// Third page: Nautical twilight times
		case 2:
			information_name.text = @"Nautical Twilight";
			rise_title_label.text = @"Start";
			set_title_label.text = @"End";
			
			double naut_start, naut_end;		// Will store the rise and set times
			
			// Populate columns 2 and 3 with sunrise/sunset times
			for (int i=0; i<6; i++)
			{
				naut_start = 0;
				naut_end = 0;
				
				nautical_twilight(	[[[days[i] description] substringWithRange:NSMakeRange(0,4)] intValue],
							 [[[days[i] description] substringWithRange:NSMakeRange(5,2)] intValue],
							 [[[days[i] description] substringWithRange:NSMakeRange(8,2)] intValue],
							 lon,
							 lat,
							 &naut_start,
							 &naut_end
							 );
				
				int tz_offset = [timezone secondsFromGMTForDate:days[i]];
				column2label[i].text = [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(naut_start*3600.0)+tz_offset]];
				column3label[i].text = [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(naut_end*3600.0)+tz_offset]];
			}
			
			status_label.text = [NSString stringWithFormat:@"All times in %@", [zoneFormat stringFromDate:[NSDate date]]];
			
			break;

		// Fourth page: Astronomical twilight times
		case 3:
			information_name.text = @"Astronomical Twilight";
			rise_title_label.text = @"Start";
			set_title_label.text = @"End";
			
			double astr_start, astr_end;		// Will store the rise and set times
			
			// Populate columns 2 and 3 with sunrise/sunset times
			for (int i=0; i<6; i++)
			{
				astr_start = 0;
				set_time = 0;
				
				astronomical_twilight(	[[[days[i] description] substringWithRange:NSMakeRange(0,4)] intValue],
							 [[[days[i] description] substringWithRange:NSMakeRange(5,2)] intValue],
							 [[[days[i] description] substringWithRange:NSMakeRange(8,2)] intValue],
							 lon,
							 lat,
							 &astr_start,
							 &astr_end
							 );
				
				int tz_offset = [timezone secondsFromGMTForDate:days[i]];
				column2label[i].text	= [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(astr_start*3600.0)+tz_offset]];
				column3label[i].text	= [timeFormat stringFromDate:[days[i] dateByAddingTimeInterval:(astr_end*3600.0)+tz_offset]];
			}
			
			status_label.text = [NSString stringWithFormat:@"All times in %@", [zoneFormat stringFromDate:[NSDate date]]];
			
			break;
			
		// NOT USED: Fifth page: Sun rise and set azimuths
		case 4:
			information_name.text = @"Solar Azimuth";
			rise_title_label.text = @"Sunrise";
			set_title_label.text = @"Sunset?";
			
			CLLocationCoordinate2D theLoc = {lon, lat};
			
			// Populate columns 2 and 3 with sunrise/sunset times
			for (int i=0; i<6; i++)
			{
				// Populate this row with the rise and set times, based on NSDate objects. Adjust them based on the timezone. (This also covers DST.)
				NSDate * thisDay = days[i];
				column2label[i].text	= [NSString stringWithFormat:@"%f", [self sunAzimuthForLocation:theLoc date:thisDay timeZone:timezone]];
				column3label[i].text	= @"derp";

			}
			
			status_label.text = @"Feature unstable at this time.";
			
			break;

		// NOT USED: Sixth page: Lunar rise and set times
		case 5:
			information_name.text = @"Lunar Rise and Set";
			rise_title_label.text = @"Moonrise";
			set_title_label.text = @"Moonset";
			
			status_label.text = @"Feature not available at this time.";
			status_label.text = [NSString stringWithFormat:@"%i", [self julianDayFromMonth:2 Day:3]];
			status_label.text = [days[0] description];
			// int stuff = [self julianDayFromMonth:2 Day:3];
			
			break;
		
		// NOT USED: Seventh page: Lunar azimuths
		case 6:
			information_name.text = @"Lunar Azimuth";
			rise_title_label.text = @"Moonrise";
			set_title_label.text = @"Moonset";
			
			status_label.text = @"Feature unavailable at this time.";
			
			break;
			
		// Default case: Shouldn't occur
		default:
			information_name.text = @"Whoops!";
			break;

	}	// end switch(pageNumber)

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)callToggleView
{
	[[AD rootViewController] toggleView];
}

#pragma mark Memory Management

- (void)dealloc
{
	// Release the NSDate objects we used for the week
	for (int i=0; i<6; i++)
	{
		[days[i] release];
	}
	
    [super dealloc];
}


@end
