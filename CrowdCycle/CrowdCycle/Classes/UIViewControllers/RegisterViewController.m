//  RegisterViewController.m

#import "RegisterViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import <libPusher/PTPusher.h>
#import <libPusher/PTPusherChannel.h>

@implementation RegisterViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; {
  if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){

  }
  return self;
}

#pragma mark - View LifeStyle

- (void)viewDidLoad; {
  [super viewDidLoad];
  UIImage *orangeButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  UIImage *orangeButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  [_registerButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
  [_registerButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
}

#pragma mark - Methods

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

    ServerController * serverController = [ServerController sharedServerController];
    User * user = (User *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:serverController.managedObjectContext] insertIntoManagedObjectContext:serverController.managedObjectContext];
    user.email = _emailTextField.text;
    user.name = _nameTextField.text;
    [serverController createUser:user withPassword:_passwordTextField.text delegate:self];
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

#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didCreateUser:(User *)aUser; {
  NSLog(@"User: %@", aUser);
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  [AppDelegate appDelegate].currrentUser = aUser;
  PTPusherChannel * channel = [[AppDelegate appDelegate].client subscribeToChannelNamed:aUser.userID];
  [channel bindToEventNamed:@"new_marker" handleWithBlock:^(PTPusherEvent * channelEvent) {
    NSLog(@"Notification");
  }];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)serverController:(ServerController *)serverController didFailWithError:(NSError *)aError; {
  if ([aError.localizedRecoverySuggestion rangeOfString:@"email already exists"].location != NSNotFound) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"That email address already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    self.view.userInteractionEnabled = YES;
    [_activityIndicator stopAnimating];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
  [textField resignFirstResponder];
  return YES;
}

@end