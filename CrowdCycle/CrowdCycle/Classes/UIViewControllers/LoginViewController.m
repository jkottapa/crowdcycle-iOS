//
//  LoginViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)viewTapped:(id)sender; {
  [self dismissKeyboard];
}

- (IBAction)loginButtonPressed:(id)sender; {
  NSString * errorMsg = nil;
  
  if ([_emailTextField.text isEqualToString:@""]) {
    errorMsg = @"Please enter your email";
    [self dismissKeyboard];
  } else if ([_passwordTextField.text isEqualToString:@""]) {
    errorMsg = @"Please enter your password";
    [self dismissKeyboard];
  }
  
  if(errorMsg != nil){
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
  } else {
    [self dismissKeyboard];
    self.view.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
    [[ServerController sharedServerController] loginWithEmail:_emailTextField.text password:_passwordTextField.text delegate:self];
  }
  
}

- (void)dismissKeyboard; {
  [_emailTextField endEditing:YES];
  [_passwordTextField endEditing:YES];
}

- (void)serverController:(ServerController *)serverController didCreateUser:(User *)aUser; {
  [serverController getUserDetails:aUser delegate:self];
  [AppDelegate appDelegate].currrentUser = aUser;
  
}

- (void)serverController:(ServerController *)serverController didGetUserDetails:(User *)aUser; {
  [AppDelegate appDelegate].currrentUser = aUser;
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  [self.navigationController popViewControllerAnimated:YES];
}
@end
