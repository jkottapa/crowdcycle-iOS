//
//  CreateMarkerViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ServerController.h"

@class Marker;

@interface CreateMarkerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ServerControllerDelegate> {
  NSString                             * _markerType;
  CLLocationCoordinate2D                 _createLocation;
  
  Marker                               * _marker;
  
  IBOutlet UIButton                    * _saveButton;
  IBOutlet UITableView                 * _tableView;
  IBOutlet UITextField                 * _titleTextField;
  IBOutlet UITextField                 * _commentTextField;
  IBOutlet UITextField                 * _descriptionTextField;
  IBOutlet UIActivityIndicatorView     * _activityIndicator;
  IBOutlet UIView                      * _voteContainerView;
  IBOutletCollection(UIButton) NSArray * _typeButtons;
  IBOutlet UIButton                    * _upVoteButton;
  IBOutlet UIButton                    * _downVoteButton;
}

@property (nonatomic) CLLocationCoordinate2D createLocation;
@property (nonatomic, retain) Marker       * marker;

- (IBAction)viewTapped:(id)sender;
- (IBAction)typeButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(UIButton *)aButton;

@end