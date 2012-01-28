//
//  OfflineLocationViewController.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 5/27/10.
//  Copyright 2010 Stephen Eisenhauer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OfflineLocationViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

	IBOutlet UITextField * latField;
	IBOutlet UITextField * lonField;
	IBOutlet UIPickerView * cityPicker;
	
	NSArray * cities;
}

@property(nonatomic, retain) NSArray * cities;

- (IBAction)saveAndDismiss:(id)sender;
- (IBAction)dismissWithoutSaving:(id)sender;

@end
