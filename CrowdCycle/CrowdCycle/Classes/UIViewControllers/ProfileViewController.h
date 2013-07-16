//
//  ProfileViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerController.h"

@interface ProfileViewController : UIViewController <UITextFieldDelegate, ServerControllerDelegate>{
  IBOutlet UITextField * _nameTextField;
  IBOutlet UITextField * _emailTextField;
  IBOutlet UITextField * _currentPasswordTextField;
  IBOutlet UITextField * _newPasswordTextField;
  IBOutlet UITextField * _confirmPasswordTextField;
  IBOutlet UIButton * _updateButton;
  IBOutlet UIButton * _logoutButton;
  IBOutlet UIScrollView * _scrollView;
  IBOutlet UIActivityIndicatorView * _activityIndicator;
}

- (IBAction)viewTapped:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;

@end
