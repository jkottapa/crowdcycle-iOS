//
//  CreateMarkerViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "CreateMarkerViewController.h"
#import "Marker.h"
#import "Comment.h"
#import "AppDelegate.h"
#import "CommentCell.h"

@implementation CreateMarkerViewController

@synthesize marker = _marker;
@synthesize createLocation = _createLocation;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; {
  if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])){
    
  }
  return self;
}

#pragma mark - View LifeStyle

- (void)viewDidLoad; {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  UIImage * orangeButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  UIImage * orangeButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  UIImage * whiteButtonImage = [[UIImage imageNamed:@"whiteButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  UIImage * whiteButtonImageHighlight = [[UIImage imageNamed:@"whiteButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  
  [_saveButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
  [_saveButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
  
  for (UIButton * typeButton in _typeButtons) {
    [typeButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
    [typeButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  }
  if(_marker){
    [[ServerController sharedServerController] getCommentsForMarker:_marker delegate:self];
  }
}

#pragma mark - Methods

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

- (IBAction)commentButtonTapped:(UIButton *)aButton; {
  ServerController * serverController = [ServerController sharedServerController];
  Comment * comment = (Comment *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:serverController.managedObjectContext] insertIntoManagedObjectContext:serverController.managedObjectContext];
  
  comment.user = [AppDelegate appDelegate].currrentUser;
  comment.marker = _marker;
  comment.text = _commentTextField.text;
  [serverController createComment:comment forMarker:_marker delegate:self];
}

- (void)dismissKeyboard; {
  [_titleTextField endEditing:YES];
  [_descriptionTextField endEditing:YES];
  [_commentTextField endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
  if(_marker){
    return _marker.comments.count;
  }
  else{
    return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
  Comment * comment = [_marker.comments.allObjects objectAtIndex:indexPath.row];
  CGSize labelSize = [comment.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0f] forWidth:292.0f lineBreakMode:NSLineBreakByWordWrapping];
  return labelSize.height + 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
  static NSString * cellIdentifier = @"CommentCell";
  CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if(!cell){
    cell = [[CommentCell alloc] init];
  }
  cell.comment = [_marker.comments.allObjects objectAtIndex:indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate Methods


#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didFailWithError:(NSError *)aError; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
}

@end
