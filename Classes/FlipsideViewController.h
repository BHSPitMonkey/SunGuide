//
//  FlipsideViewController.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 1/26/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunGuideAppDelegate.h"
#import "Shortcuts.h"

@interface FlipsideViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate> {

	IBOutlet UITableView * settingsTable;
	
	IBOutlet UISwitch * locationServiceSetting;
	IBOutlet UITextField * defaultLongitudeField;
	IBOutlet UITextField * defaultLatitudeField;
	
	IBOutlet UILabel * currentLocationLabel;
	IBOutlet UIButton * saveCurrentLocationButton;
	
	IBOutlet UIButton * saveSettingsButton;
}

- (IBAction)saveCurrentLocation:(id)sender;		// Method for saving the current location as the preferred one
- (IBAction)saveSettings:(id)sender;			// Method for saving settings
- (IBAction)aboutThisApp:(id)sender;			// Method for showing About dialog

@end
