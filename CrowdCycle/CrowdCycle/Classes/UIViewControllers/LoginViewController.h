//
//  LoginViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController {
    IBOutlet UITextField * _emailTextField;
    IBOutlet UITextField * _passwordTextField;
    IBOutlet UIButton * _loginButton;
    IBOutlet UIButton * _registerButton;
    IBOutlet UIActivityIndicatorView * _activityIndicator;
}

- (IBAction)viewTapped:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
@end
