//
//  CreateMarkerViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CreateMarkerViewController.h"
#import "MainViewController.h"
#import "Marker.h"
#import "Comment.h"
#import "User.h"
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
  _voteContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  _voteContainerView.layer.borderWidth = 1.0f;
  _voteContainerView.layer.cornerRadius = 5;
  _voteContainerView.layer.masksToBounds = YES;
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
  [_deleteButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
  [_deleteButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
  [_upVoteButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
  [_upVoteButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  [_downVoteButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
  [_downVoteButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  [_commentButton setBackgroundImage:orangeButtonImage forState:UIControlStateNormal];
  [_commentButton setBackgroundImage:orangeButtonImageHighlight forState:UIControlStateHighlighted];
  
  for (UIButton * typeButton in _typeButtons) {
    [typeButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
    [typeButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  }
  if(_marker){
    _titleNavigationItem.title = @"Marker";
    [self initiateTypeButtons];
    _titleTextField.text = _marker.title;
    _descriptionTextField.text = _marker.markerDescription;
    // not logged in or not creator
    if (![AppDelegate appDelegate].currrentUser || ![_marker.ownerID isEqualToString:[AppDelegate appDelegate].currrentUser.userID]) {
      _titleTextField.borderStyle = UITextBorderStyleNone;
      _titleTextField.textColor = [UIColor whiteColor];
      [_titleTextField setEnabled:NO];
      _descriptionTextField.borderStyle = UITextBorderStyleNone;
      _descriptionTextField.textColor = [UIColor whiteColor];
      [_descriptionTextField setEnabled:NO];
      [_saveButton setHidden:YES];
      [_deleteButton setHidden:YES];
      for (UIButton * typeButton in _typeButtons) {
        [typeButton setEnabled:NO];
      }
      _editableMode = NO;
    } else {
      // edit
      _markerType = _marker.type;
      _editableMode = YES;
    }
    _voteLabel.text = [NSString stringWithFormat:@"%i", ([_marker.upVotes intValue] - [_marker.downVotes intValue])];
    [[ServerController sharedServerController] getCommentsForMarker:_marker delegate:self];
  } else {
    _editableMode = YES;
    _upVoteButton.hidden = YES;
    _downVoteButton.hidden = YES;
    _voteLabel.hidden = YES;
    _commentTextField.hidden = YES;
    _commentButton.hidden = YES;
    _deleteButton.hidden = YES;
  }
  
  if(![AppDelegate appDelegate].currrentUser){
    _commentTextField.hidden = YES;
    _commentButton.hidden = YES;
  }
}

#pragma mark - Methods

- (void) initiateTypeButtons; {
  for (UIButton * typeButton in _typeButtons) {
    if([typeButton.titleLabel.text isEqualToString:@"Point of Interest"] && [_marker.type isEqualToString:@"pointOfIntrest"]) {
      typeButton.alpha = 1;
    } else if([typeButton.titleLabel.text isEqualToString:@"Physical Hazard"] && [_marker.type isEqualToString:@"physicalHazard"]) {
      typeButton.alpha = 1;
    } else if([typeButton.titleLabel.text isEqualToString:@"People Hazard"] && [_marker.type isEqualToString:@"peopleHazard"]) {
      typeButton.alpha = 1;
    } else if([typeButton.titleLabel.text isEqualToString:@"Caution"] && [_marker.type isEqualToString:@"caution"]) {
      typeButton.alpha = 1;
    }
  }
}

- (IBAction)typeButtonTapped:(UIButton*)sender; {
  if (_editableMode) {
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
    
    if (_marker) {
      // edit existing
      _marker.markerDescription = _descriptionTextField.text;
      _marker.title = _titleTextField.text;
      _marker.type = _markerType;
      [[ServerController sharedServerController] editMarker:_marker delegate:self];
    } else{
      // create new
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
}

- (IBAction)viewTapped:(id)sender; {
  [self dismissKeyboard];
}

- (IBAction)commentButtonTapped:(UIButton *)aButton; {
  [_commentTextField endEditing:YES];
  ServerController * serverController = [ServerController sharedServerController];
  Comment * comment = (Comment *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:serverController.managedObjectContext] insertIntoManagedObjectContext:serverController.managedObjectContext];
  
  comment.user = [AppDelegate appDelegate].currrentUser;
  comment.text = _commentTextField.text;
  [serverController createComment:comment forMarker:_marker delegate:self];
}

- (void)castVote:(int)vote; {
  if ([AppDelegate appDelegate].currrentUser) {
    self.view.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
    [[ServerController sharedServerController] voteOnMarker:_marker vote:vote delegate:self];
  } else {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login to vote" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
  }
}

- (IBAction)upVoteButtonTapped:(UIButton *)aButton; {
  [self castVote:1];
}

- (IBAction)downVoteButtonTapped:(UIButton *)aButton; {
  [self castVote:-1];
}

- (IBAction)deleteButtonTapped:(UIButton *)aButton; {
  [self dismissKeyboard];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Confirm delete, this action cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"Delete"]) {
    self.view.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
    [[ServerController sharedServerController] deleteMarker:_marker delegate:self];
  }
}

- (void)dismissKeyboard; {
  [_titleTextField endEditing:YES];
  [_descriptionTextField endEditing:YES];
  [_commentTextField endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField; {
  if([textField isEqual:_commentTextField]){
    _tableView.contentSize = CGSizeMake(_tableView.contentSize.width, _tableView.contentSize.height + 216.0f);
    CGPoint newOffset = CGPointMake(0.0f, _tableView.contentOffset.y + 216.0f);
    [_tableView setContentOffset:newOffset animated:YES];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField; {
  if([textField isEqual:_commentTextField]){
    [UIView animateWithDuration:0.31f
                     animations:^{
                       _tableView.contentSize = CGSizeMake(_tableView.contentSize.width, _tableView.contentSize.height - 216.0f);
                     }];
  }
}

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
    return _commentsArray.count;
  }
  else{
    return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
  Comment * comment = [_commentsArray objectAtIndex:indexPath.row];
  CGSize labelSize = [comment.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0f] forWidth:292.0f lineBreakMode:NSLineBreakByWordWrapping];
  return labelSize.height + 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
  static NSString * cellIdentifier = @"CommentCell";
  CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if(!cell){
    cell = [[CommentCell alloc] init];
  }
  cell.comment = [_commentsArray objectAtIndex:indexPath.row];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath; {
  Comment * comment = [_commentsArray objectAtIndex:indexPath.row];
  
  if([comment.user.userID isEqualToString:[AppDelegate appDelegate].currrentUser.userID]){
    return YES;
  }
  else{
    return NO;
  }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath; {
  Comment * comment = [_commentsArray objectAtIndex:indexPath.row];
  
  if([comment.user.userID isEqualToString:[AppDelegate appDelegate].currrentUser.userID] && editingStyle == UITableViewCellEditingStyleDelete){
    ServerController * serverController = [ServerController sharedServerController];
    [serverController deleteComment:comment delegate:self];
    //[serverController getCommentsForMarker:_marker delegate:self];
    return UITableViewCellEditingStyleDelete;
  }
  else{
    return UITableViewCellEditingStyleNone;
  }
}

#pragma mark - UITableViewDelegate Methods


#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didCreateComment:(Comment *)aComment; {
  _commentTextField.text = @"";
  [serverController getCommentsForMarker:_marker delegate:self];
}

- (void)serverController:(ServerController *)serverController didGetCommentsForMarker:(Marker *)aMarker; {
  _marker = aMarker;
  _commentsArray = [_marker.comments.allObjects sortedArrayUsingComparator:^NSComparisonResult(Comment * obj1, Comment * obj2) {
    return [obj1.dateCreated compare:obj2.dateCreated];
  }];
  [_tableView reloadData];
}

- (void)serverController:(ServerController *)serverController didVoteMarker:(Marker *)aMarker; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  _voteLabel.text = [NSString stringWithFormat:@"%i", ([aMarker.upVotes intValue] - [aMarker.downVotes intValue])];
}

- (void)serverController:(ServerController *)serverController didFailWithError:(NSError *)aError; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  _commentsArray = [_marker.comments.allObjects sortedArrayUsingComparator:^NSComparisonResult(Comment * obj1, Comment * obj2) {
    return [obj1.dateCreated compare:obj2.dateCreated];
  }];
  [_tableView reloadData];
  
  if ([aError.localizedRecoverySuggestion rangeOfString:@"can not cast the same vote twice"].location != NSNotFound) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You already casted that vote" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
  }
}

- (void)serverController:(ServerController *)serverController didCreateMarker:(Marker *)aMarker; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)serverController:(ServerController *)serverController didEditMarker:(Marker *)aMarker; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  MainViewController * vc = [[self.navigationController viewControllers] objectAtIndex:0];
  [vc deletePin:aMarker.markerID];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)serverController:(ServerController *)serverController didDeleteMarker:(Marker *)aMarker; {
  self.view.userInteractionEnabled = YES;
  [_activityIndicator stopAnimating];
  MainViewController * vc = [[self.navigationController viewControllers] objectAtIndex:0];
  [vc deletePin:aMarker.markerID];
  [self.navigationController popViewControllerAnimated:YES];
}
@end
