//
//  FlipsideViewController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "Shortcuts.h"

@implementation FlipsideViewController


- (void)viewDidLoad {

    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	settingsTable.backgroundColor = [UIColor viewFlipsideBackgroundColor];

}

// Called when the view is shown, or by other objects wishing to force a refresh
- (void)viewDidAppear:(BOOL)animated {
	
	[settingsTable reloadData];
}

// Save the current location as the preferred location
- (IBAction)saveCurrentLocation:(id)sender {
	
	if ([AD currentCoordinate] != nil) {
		
		[UD setDouble:[AD currentCoordinate]->latitude forKey:PREF_LATITUDE];
		[UD setDouble:[AD currentCoordinate]->longitude forKey:PREF_LONGITUDE];
	}
	
	[settingsTable reloadData];
}

// Deprecated
- (IBAction)saveSettings:(id)sender {			// Method for saving settings

	// Save the values in the text fields
	[UD setDouble:[defaultLongitudeField.text doubleValue] forKey:PREF_LONGITUDE];
	[UD setDouble:[defaultLatitudeField.text doubleValue] forKey:PREF_LATITUDE];

	// Hide the keyboard
	[defaultLongitudeField resignFirstResponder];
	[defaultLatitudeField resignFirstResponder];

	// Show an alert
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"SunGuide" message:@"Your preferences have been saved." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show]; [alert release];

}

- (IBAction)aboutThisApp:(id)sender {			// Method for showing About dialog
	
	// Show an alert
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"About" message:@"SunGuide was developed by Stephen Eisenhauer.\n\nhttp://stepheneisenhauer.com/\nsunguide" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles:@"Visit Website",@"Email Feedback",nil];
	[alert show]; [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)button {
	if (button == 1)			// Visit Site
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://stepheneisenhauer.com/sunguide"]];
	else if (button == 2) {		// Email Developer
		BOOL opened = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:sunguide@stepheneisenhauer.com?subject=SunGuide%20Feedback"]];
		if (opened == NO) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"SunGuide" message:@"Oops! There was a problem creating an e-mail message.\n\nPlease write to SunGuide@StephenEisenhauer.com for help." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
			[alert show]; [alert release];
		}
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	// First text field returned
	if (textField.tag == 1) {
		[textField resignFirstResponder];
	}
	// Second text field returned
	else if (textField.tag == 2) {
		[textField resignFirstResponder];
	}
	
	return YES;
}


#pragma mark TableView Rows

/* Sketch
 
 Preferred Location		12.3, 52.3 >
 
 Current Location			13.2, 53.2
	Make this my preferred location
 
			About this App
 
*/

// Row identifiers
typedef enum {
	NullRow,
	PreferredLocationRow,
	UseCurrentRow,
	CurrentLocationRow,
	MakePreferredRow,
	AboutAppRow
} SettingRowType;

// Convert an indexPath into a row identifier
- (SettingRowType)rowForIndexPath:(NSIndexPath *)indexPath {
	int section = indexPath.section;
	int row = indexPath.row;

	if (section == 0) {
		if (row == 0) return PreferredLocationRow;
	}
	else if (section == 1) {
		if (row == 0) return UseCurrentRow;
		else if (row == 1) return CurrentLocationRow;
		else if (row == 2) return MakePreferredRow;
	}
	else if (section == 2) {
		if (row == 0) return AboutAppRow;
	}
	return NullRow;
}

#pragma mark TableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[settingsTable deselectRowAtIndexPath:indexPath animated:YES];
	
	SettingRowType row = [self rowForIndexPath:indexPath];
	
	switch (row) {
		case PreferredLocationRow:
			[AD showLocationPicker];
			break;
		case UseCurrentRow:
			// Toggle the preference
			[UD setBool:![UD boolForKey:USE_LOCATION] forKey:USE_LOCATION];
			NSLog(@"USE_LOCATION is now %d", [UD boolForKey:USE_LOCATION]);
			break;
		case MakePreferredRow:
			[self saveCurrentLocation:nil];
			break;
		case AboutAppRow:
			[self aboutThisApp:nil];
			break;
		default:
			break;
	}
	
	[tableView reloadData];
}

#pragma mark TableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
		case 2:
			return 1;
		default:
			return 0;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	SettingRowType row = [self rowForIndexPath:indexPath];
	
	switch (row) {
		case PreferredLocationRow:
			cell.textLabel.text = [NSString stringWithFormat:@"Preferred Location: %3.1f %3.1f",
								   [UD doubleForKey:PREF_LATITUDE],
								   [UD doubleForKey:PREF_LONGITUDE]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case UseCurrentRow:
			cell.textLabel.text = @"Use Current Location when available";
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.textLabel.minimumFontSize = 8;
			break;
		case CurrentLocationRow:
			if ([AD currentCoordinate] != nil)
				cell.textLabel.text = [NSString stringWithFormat:@"Current Location: %3.1f %3.1f",
								   [AD currentCoordinate]->latitude,
								   [AD currentCoordinate]->longitude];
			else
				cell.textLabel.text = @"Current Location Unknown";
			cell.textLabel.textColor = ([UD boolForKey:USE_LOCATION]) ? [UIColor blackColor] : [UIColor grayColor];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		case MakePreferredRow:
			cell.textLabel.text = @"Make this my preferred location";
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			if ([AD currentCoordinate] != nil) {
				cell.textLabel.textColor = [UIColor blackColor];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
			else {
				cell.textLabel.textColor = [UIColor grayColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		case AboutAppRow:
			cell.textLabel.text = @"About this App";
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		default:
			break;
	}
	
	return cell;
}

#pragma mark Other Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
