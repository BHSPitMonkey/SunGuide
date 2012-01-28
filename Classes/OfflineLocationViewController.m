//
//  OfflineLocationViewController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 5/27/10.
//  Copyright 2010 Stephen Eisenhauer. All rights reserved.
//

#import "OfflineLocationViewController.h"
#import "SunGuideAppDelegate.h"
#import "Shortcuts.h"

@implementation OfflineLocationViewController

@synthesize cities;

#pragma mark Initialization Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

	// Load cities plist
	NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"Cities" ofType:@"plist"];
	self.cities = [NSArray arrayWithContentsOfFile:plistPath];
	NSLog(@"Cities array has %d entries", [cities count]);
	[cityPicker reloadComponent:0];
	
	// Populate fields with stored prefs
	latField.text = [NSString stringWithFormat:@"%3.3f", [UD doubleForKey:PREF_LATITUDE]];
	lonField.text = [NSString stringWithFormat:@"%3.3f", [UD doubleForKey:PREF_LONGITUDE]];
}

#pragma mark Button Callbacks

// TODO
- (IBAction)saveAndDismiss:(id)sender
{	
	// Save new defaults
	NSLog(@"Saving new preferred coordinates based on user entry.");
	[UD setDouble:[latField.text doubleValue] forKey:PREF_LATITUDE];
	[UD setDouble:[lonField.text doubleValue] forKey:PREF_LONGITUDE];
	[UD setBool:YES forKey:SETUP_DONE];
	
	// TODO: Remember picker selection for next time
	//[UD setDouble:theMapView.region.span.latitudeDelta forKey:MAP_LATITUDE_SPAN];
	//[UD setDouble:theMapView.region.span.longitudeDelta forKey:MAP_LONGITUDE_SPAN];
	
	// Dismiss
	[AD dismissLocationPicker];
}

- (IBAction)dismissWithoutSaving:(id)sender
{
	NSLog(@"Dismissing without saving changes.");
	[UD setBool:YES forKey:SETUP_DONE];
	[AD dismissLocationPicker];
}

#pragma mark Text Field Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// First text field returned
	if (textField == latField) {
		[lonField becomeFirstResponder];
	}
	// Second text field returned
	else if (textField == lonField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

#pragma mark UIPicker methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{	
	if (cities != nil)
		return [cities count]+1;
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (row == 0)
		return @"Choose a City";
	return [[cities objectAtIndex:row-1] valueForKey:@"cityNameKey"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// 0th row does nothing
	if (row == 0)
		return;

	// Cities start at row 1 in picker, so we will simplify things here.
	int cityindex = row-1;
	
	latField.text = [NSString stringWithFormat:@"%@", [[cities objectAtIndex:cityindex] valueForKey:@"latitudeKey"]];
	lonField.text = [NSString stringWithFormat:@"%@", [[cities objectAtIndex:cityindex] valueForKey:@"longitudeKey"]];
					 
}

#pragma mark Other Methods

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
