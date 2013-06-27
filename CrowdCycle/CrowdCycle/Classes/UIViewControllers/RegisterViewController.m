//
//  RegisterViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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

- (IBAction)registerButtonTapped:(id)sender; {
    NSString * errorMsg = nil;
    
    if ([_emailTextField.text isEqualToString:@""]) {
        errorMsg = @"Please enter an email";
        [self dismissKeyboard];
    } else if ([_nameTextField.text isEqualToString:@""]) {
        errorMsg = @"Please enter a name";
        [self dismissKeyboard];
    } else if ([_passwordTextField.text isEqualToString:@""]) {
        errorMsg = @"Please enter a password";
        [self dismissKeyboard];
    } else if (![_confirmPasswordTextField.text isEqualToString:_passwordTextField.text]) {
        errorMsg = @"Passwords do not match";
        [self dismissKeyboard];
    }
    
    if(errorMsg != nil){
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    } else {
        [self dismissKeyboard];
        self.view.userInteractionEnabled = NO;
        [_activityIndicator startAnimating];
    }
}

- (IBAction)viewTapped:(id)sender; {
    [self dismissKeyboard];
}

- (void)dismissKeyboard; {
    [_emailTextField endEditing:YES];
    [_nameTextField endEditing:YES];
    [_passwordTextField endEditing:YES];
    [_confirmPasswordTextField endEditing:YES];
}
@end
