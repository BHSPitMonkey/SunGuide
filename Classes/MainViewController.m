//
//  MainViewController.m
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "DataViewController.h"
#import "DataView.h"
#import "FlipsideViewController.h"
#import "SunGuideAppDelegate.h"

@implementation MainViewController

@synthesize pages;

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
	// Load data views for pages
	self.pages = [NSMutableArray arrayWithCapacity:NUM_PAGES];
	for (int i=0; i<NUM_PAGES; i++)
	{
		if (SGDEBUG) NSLog(@"Loading page %d\n", i);

		// Instantiate the dataviewcontroller
		DataViewController * datacontroller = [[DataViewController alloc] initWithPageNumber:i];
		
		// Store its pointer for later and retain it in memory.
		dataviewcontrollers[i] = datacontroller;
		[dataviewcontrollers[i] retain];

		// Add this dataviewcontroller's view to the pages array
		[pages addObject: datacontroller.view];
	}
	
	scrollView = [[PageScrollView alloc] initWithFrame:self.view.frame];
	scrollView.pages = pages;
	scrollView.delegate = self;
	self.view = scrollView;	

	[super viewDidLoad];
}

#pragma mark Class Methods

// Repopulate the data in all the data views.
- (void)repopulateAllDataViews
{
	// Repopulate the dataviews' data.
	for (int i=0; i<NUM_PAGES; i++)
	{
		if (dataviewcontrollers[i] != nil)
			 [dataviewcontrollers[i] populateWithData];
		else
			NSLog(@"Tried to repopulate page %d, but could not!");
	}
}

#pragma mark UI Callbacks

// Called each time the mainView is re-displayed.
- (void)viewDidAppear:(BOOL)animated
{	
	[self repopulateAllDataViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
-(void) pageScrollViewDidChangeCurrentPage:(PageScrollView *)pageScrollView currentPage:(int)currentPage
{
	if (SGDEBUG) NSLog(@"I'm now on page %d\n", currentPage);
} */

#pragma mark Memory Management

- (void)dealloc
{
	// Release all four data view controllers
	for (int i=0; i<NUM_PAGES; i++)
		[dataviewcontrollers[i] release];
	[pages release];
    [super dealloc];
}

@end
