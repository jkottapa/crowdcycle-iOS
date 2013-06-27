//
//  ProfileViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController {
    IBOutlet UITextField * _nameTextField;
    IBOutlet UITextField * _emailTextField;
    IBOutlet UITextField * _currentPasswordTextField;
    IBOutlet UITextField * _newPasswordTextField;
    IBOutlet UITextField * _confirmPasswordTextField;
    IBOutlet UIButton * _updateButton;
}

- (IBAction)viewTapped:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;

@end
