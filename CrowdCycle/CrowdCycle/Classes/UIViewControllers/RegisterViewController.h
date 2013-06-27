//
//  RegisterViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController {
    IBOutlet UITextField * _nameTextField;
    IBOutlet UITextField * _emailTextField;
    IBOutlet UITextField * _passwordTextField;
    IBOutlet UITextField * _confirmPasswordTextField;
    IBOutlet UIButton * _registerButton;
    IBOutlet UIActivityIndicatorView * _activityIndicator;
}

- (IBAction)registerButtonTapped:(id)sender;
- (IBAction)viewTapped:(id)sender;

@end
