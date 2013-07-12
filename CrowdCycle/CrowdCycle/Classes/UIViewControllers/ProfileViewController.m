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
  [_logoutButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
  [_logoutButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
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
  NSString * newName = nil;
  NSString * newPassword = nil;
  if (![_nameTextField.text isEqualToString:@""]) {
    newName = _nameTextField.text;
  }
  if (![_newPasswordTextField.text isEqualToString:@""]) {
    newPassword = _newPasswordTextField.text;
  }
  if (!newName && !newPassword) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No changes to update" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    return;
  }
  if ([_currentPasswordTextField.text isEqualToString:@""]) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your current password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    return;
  }
  
  self.view.userInteractionEnabled = NO;
  [_activityIndicator startAnimating];

  [[ServerController sharedServerController] editUser:[AppDelegate appDelegate].currrentUser withPassword:_currentPasswordTextField.text newPassword:newPassword newName:newName delegate:self];
}

- (IBAction)logoutButtonPressed:(id)sender; {
  [self dismissKeyboard];
  self.view.userInteractionEnabled = NO;
  [_activityIndicator startAnimating];
  [[ServerController sharedServerController] logout:self];
}

- (void)dismissKeyboard; {
  [_emailTextField endEditing:YES];
  [_nameTextField endEditing:YES];
  [_newPasswordTextField endEditing:YES];
  [_confirmPasswordTextField endEditing:YES];
  [_currentPasswordTextField endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
  [textField resignFirstResponder];
  return YES;
}

- (void)serverController:(ServerController *)serverController didLogout:(bool)success {
  [AppDelegate appDelegate].currrentUser = nil;
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)serverController:(ServerController *)serverController didEditUser:(User *)aUser; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  [self.view setNeedsDisplay];
  _nameTextField.text = aUser.name;
  _emailTextField.text = aUser.email;
  _newPasswordTextField.text = @"";
  _confirmPasswordTextField.text = @"";
  _currentPasswordTextField.text = @"";
  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Account updated" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
  [alertView show];
  return;
}
@end
