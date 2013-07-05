//
//  ProfileViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import "ServerController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  User * user = [AppDelegate appDelegate].currrentUser;
  _nameTextField.text = user.name;
  _emailTextField.text = user.email;
	// Do any additional setup after loading the view.
    UIImage *orangeButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *orangeButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_updateButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
    [_updateButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)viewTapped:(id)sender; {
  [self dismissKeyboard];
}

- (IBAction)updateButtonPressed:(id)sender; {
  [self dismissKeyboard];
}

- (void)dismissKeyboard; {
  [_emailTextField endEditing:YES];
  [_nameTextField endEditing:YES];
  [_newPasswordTextField endEditing:YES];
  [_confirmPasswordTextField endEditing:YES];
  [_currentPasswordTextField endEditing:YES];
}
@end
