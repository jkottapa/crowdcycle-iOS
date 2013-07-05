//
//  CreateMarkerViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CreateMarkerViewController : UIViewController {
  IBOutletCollection(UIButton) NSArray * _typeButtons;
  IBOutlet UIButton * _saveButton;
  IBOutlet UITextField * _titleTextField;
  IBOutlet UITextField * _descriptionTextField;
  NSString * _markerType;
}
- (IBAction)typeButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)viewTapped:(id)sender;
@property (nonatomic) CLLocationCoordinate2D createLocation;
@end