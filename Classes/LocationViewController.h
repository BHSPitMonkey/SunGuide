//
//  LocationViewController.h
//  SunGuide
//
//  Created by Stephen Eisenhauer on 5/26/10.
//  Copyright 2010 Stephen Eisenhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController <MKMapViewDelegate> {

	IBOutlet UIBarButtonItem * saveButton;
	IBOutlet UILabel * coordLabel;
	IBOutlet MKMapView * theMapView;

}

- (IBAction)saveAndDismiss:(id)sender;
- (IBAction)dismissWithoutSaving:(id)sender;

@end
