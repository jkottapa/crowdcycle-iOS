//
//  CreateMarkerViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/28/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CreateMarkerViewController.h"
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
  _titleTextField.text = _marker.title;
  _descriptionTextField.text = _marker.markerDescription;
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
  [_upVoteButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
  [_upVoteButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  [_downVoteButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
  [_downVoteButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  
  for (UIButton * typeButton in _typeButtons) {
    [typeButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
    [typeButton setBackgroundImage:whiteButtonImageHighlight forState:UIControlStateHighlighted];
  }
  if(_marker){
    // not logged in or not creator
    if (![AppDelegate appDelegate].currrentUser || ![_marker.owner.userID isEqualToString:[AppDelegate appDelegate].currrentUser.userID]) {
      _titleTextField.borderStyle = UITextBorderStyleNone;
      [_titleTextField setEnabled:NO];
      _descriptionTextField.borderStyle = UITextBorderStyleNone;
      [_descriptionTextField setEnabled:NO];
      [_saveButton setHidden:YES];
      _editableMode = NO;
    } else {
      _editableMode = YES;
    }
    _voteLabel.text = [NSString stringWithFormat:@"%i", ([_marker.upVotes intValue] - [_marker.downVotes intValue])];
    [[ServerController sharedServerController] getCommentsForMarker:_marker delegate:self];
  } else {
    _editableMode = YES;
    [_voteContainerView setHidden:YES];
  }
  
  if(![AppDelegate appDelegate].currrentUser){
    _commentTextField.hidden = YES;
    _sendButton.hidden = YES;
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
  
  if([comment.user isEqual:[AppDelegate appDelegate].currrentUser]){
    return YES;
  }
  else{
    return NO;
  }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath; {
  Comment * comment = [_commentsArray objectAtIndex:indexPath.row];
  
  if([comment.user isEqual:[AppDelegate appDelegate].currrentUser] && editingStyle == UITableViewCellEditingStyleDelete){
    ServerController * serverController = [ServerController sharedServerController];
    [serverController deleteComment:comment delegate:self];
    [serverController.managedObjectContext deleteObject:comment];
    [serverController getCommentsForMarker:_marker delegate:self];
    return UITableViewCellEditingStyleDelete;
  }
  else{
    return UITableViewCellEditingStyleNone;
  }
}

#pragma mark - UITableViewDelegate Methods


#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didCreateComment:(Comment *)aComment; {
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
  if ([aError.localizedRecoverySuggestion rangeOfString:@"can not cast the same vote twice"].location != NSNotFound) {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You already casted that vote" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
  }
}

@end
