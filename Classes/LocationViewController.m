//
//  LocationViewController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 5/26/10.
//  Copyright 2010 Stephen Eisenhauer. All rights reserved.
//

#import "LocationViewController.h"
#import "SunGuideAppDelegate.h"
#import "Shortcuts.h"

@implementation LocationViewController

#pragma mark Important Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[super viewDidLoad];
	
	MKCoordinateRegion reg = theMapView.region;
	
	// If we have stored values for the map's span, apply them to reg
	if (([UD doubleForKey:MAP_LATITUDE_SPAN] > 0) && ([UD doubleForKey:MAP_LONGITUDE_SPAN] > 0)) {
		reg.span.latitudeDelta = [UD doubleForKey:MAP_LATITUDE_SPAN];
		reg.span.longitudeDelta = [UD doubleForKey:MAP_LONGITUDE_SPAN];
	}
	
	// Re-center the map over our last preferred
	reg.center.latitude = [UD doubleForKey:PREF_LATITUDE];
	reg.center.longitude = [UD doubleForKey:PREF_LONGITUDE];
	
	// Apply reg to the map view
	[theMapView setRegion:reg animated:YES];
}

- (IBAction)saveAndDismiss:(id)sender {

	// Save new defaults
	NSLog(@"Saving new preferred coordinates based on map.");
	[UD setDouble:theMapView.centerCoordinate.latitude forKey:PREF_LATITUDE];
	[UD setDouble:theMapView.centerCoordinate.longitude forKey:PREF_LONGITUDE];
	[UD setBool:YES forKey:SETUP_DONE];
	
	// Remember map position and region for next time
	[UD setDouble:theMapView.region.span.latitudeDelta forKey:MAP_LATITUDE_SPAN];
	[UD setDouble:theMapView.region.span.longitudeDelta forKey:MAP_LONGITUDE_SPAN];
	
	// Dismiss
	[AD dismissLocationPicker];
}

- (IBAction)dismissWithoutSaving:(id)sender {
	NSLog(@"Dismissing without saving changes.");
	[UD setBool:YES forKey:SETUP_DONE];
	[AD dismissLocationPicker];
}

#pragma mark MapView Delegate Methods

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	
	coordLabel.text = [NSString stringWithFormat:@"%3.2f N %3.2f E", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude];
}

#pragma mark Other Methods

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
