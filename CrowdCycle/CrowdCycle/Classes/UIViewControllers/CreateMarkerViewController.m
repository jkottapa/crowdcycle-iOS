//
//  CreateMarkerViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "CreateMarkerViewController.h"
#import "Marker.h"

@interface CreateMarkerViewController ()

@end

@implementation CreateMarkerViewController

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
    UIImage *orangeButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *orangeButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *whiteButtonImage = [[UIImage imageNamed:@"whiteButton.png"]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *whiteButtonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"]
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    [_saveButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
    [_saveButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
    for (UIButton *typeButton in _typeButtons) {
        [typeButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
        [typeButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)typeButtonTapped:(UIButton*)sender; {
  for (UIButton * typeButton in _typeButtons) {
    typeButton.alpha = .5;
  }
  sender.alpha = 1;
  if([sender.titleLabel.text isEqualToString:@"Point of Interest"]) {
    _markerType = @"pointOfIntrest";
  } else if ([sender.titleLabel.text isEqualToString:@"Physical Hazard"]) {
    _markerType = @"physicalHazard";
  } else if ([sender.titleLabel.text isEqualToString:@"People Hazard"]) {
    _markerType = @"peopleHazard";
  } else if ([sender.titleLabel.text isEqualToString:@"Caution"]) {
    _markerType = @"caution";
  }
}

- (IBAction)saveButtonTapped:(UIButton*)sender; {
  NSString * errorMsg = nil;
  
  if (_markerType == nil) {
    errorMsg = @"Please select your marker type";
    [self dismissKeyboard];
  } else if ([_titleTextField.text isEqualToString:@""]) {
    errorMsg = @"Please enter a title";
    [self dismissKeyboard];
  } else if ([_descriptionTextField.text isEqualToString:@""]) {
    errorMsg = @"Please enter a description";
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
    Marker * marker = (Marker *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Marker" inManagedObjectContext:serverController.managedObjectContext] insertIntoManagedObjectContext:serverController.managedObjectContext];
    
    marker.latitude = [NSNumber numberWithDouble:_createLocation.latitude];
    marker.longitude = [NSNumber numberWithDouble:_createLocation.longitude];
    marker.markerDescription = _descriptionTextField.text;
    marker.title = _titleTextField.text;
    marker.type = _markerType;
    [serverController createMarker:marker delegate:self];
  }
}

- (IBAction)viewTapped:(id)sender; {
  [self dismissKeyboard];
}

- (void)dismissKeyboard; {
  [_titleTextField endEditing:YES];
  [_descriptionTextField endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didFailWithError:(NSError *)aError; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
}

@end
