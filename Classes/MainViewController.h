//
//  MainViewController.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageScrollView.h"
#import "DataViewController.h"

#define NUM_PAGES 4

@interface MainViewController : UIViewController <PageScrollViewDelegate>
{
	NSMutableArray * pages;
	PageScrollView * scrollView;
	
	DataViewController * dataviewcontrollers[NUM_PAGES];
}

- (void)repopulateAllDataViews;

@property (nonatomic, retain) NSMutableArray * pages;

@end
