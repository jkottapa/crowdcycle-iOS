//
//  MainViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "ServerController.h"
#import "CreateMarkerViewController.h"
#import "Marker.h"
#import "MarkerPin.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize locationManager, currentLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated {
  [self loadPinsOnMap];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  _pinsOnMap = [NSMutableDictionary dictionary];
  _highlightPin = nil;
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  [locationManager startMonitoringSignificantLocationChanges];
  [_mapView setDelegate:self];
  
  UIImage *buttonImage = [[UIImage imageNamed:@"blackButton.png"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
  for (UIButton *typeButton in _typeButtons) {
    [typeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [typeButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
  }
  
  markerType[0] = @"createNewMarker";
  markerType[1] = @"pointOfIntrest";
  markerType[2] = @"peopleHazard";
  markerType[3] = @"physicalHazard";
  markerType[4] = @"caution";
  
  for (int i = 1; i < 5; i++) {
    showType[i] = YES;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)profileButtonTapped:(id)sender; {
  if([AppDelegate appDelegate].currrentUser){
    [self performSegueWithIdentifier:@"ProfileViewController" sender:self];
  }
  else{
    [self performSegueWithIdentifier:@"LoginViewController" sender:self];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation; {
  self.currentLocation = newLocation;
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([newLocation coordinate], 1000, 1000);
  [_mapView setRegion:region animated:YES];
  userLocated = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error; {
  if(error.code == kCLErrorDenied) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location service required"
                                                    message:@"CrowdCycle requires your current location to function, please enable and restart the app."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  } else if(error.code == kCLErrorLocationUnknown) {
    // retry
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated; {
  [self loadPinsOnMap];
}

- (void)loadPinsOnMap; {
  if (userLocated == YES) {
    MKMapRect mRect = _mapView.visibleMapRect;
    MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
    MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
    CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
    CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
    [[ServerController sharedServerController] getMarkersWithDelegate:self
                                                                 lat1:[NSNumber numberWithDouble:neCoord.latitude]
                                                                long1:[NSNumber numberWithDouble:neCoord.longitude]
                                                                 lat2:[NSNumber numberWithDouble:swCoord.latitude]
                                                                long2:[NSNumber numberWithDouble:swCoord.longitude]];
  }
}

- (void)dropPinButtonTapped:(id)sender; {
  if([AppDelegate appDelegate].currrentUser){
    if (_createPin == nil) {
      _createPin = [[MarkerPin  alloc] init];
      _createPin.coordinate = _mapView.centerCoordinate;
      _createPin.type = @"createNewMarker";
      _createPin.title = @"Create new marker";
      _createPin.subtitle = @"drag pin to desired location";
      [_mapView addAnnotation:_createPin];
      [_mapView selectAnnotation:_createPin animated:YES];
    } else {
      _createPin.coordinate = _mapView.centerCoordinate;
      [[_mapView viewForAnnotation:_createPin] setHidden:NO];
      [_mapView selectAnnotation:_createPin animated:YES];
    }
  }
  else{
    [self performSegueWithIdentifier:@"LoginViewController" sender:self];
  }
}

- (IBAction)typeButtonTapped:(UIButton*)sender; {
  int type = sender.tag;
  if (showType[type]) {
    sender.alpha = 0.4;
    showType[type] = NO;
  } else {
    sender.alpha = 1;
    showType[type] = YES;
  }
  
  for (id mid in _pinsOnMap) {
    MarkerPin* pin = [_pinsOnMap objectForKey:mid];
    for (int i = 1; i < 5; i++) {
      if ([pin.type isEqualToString:markerType[i]]) {
        if (showType[i] == YES) {
          [[_mapView viewForAnnotation:pin] setHidden:NO];
        } else {
          [[_mapView viewForAnnotation:pin] setHidden:YES];
        }
      }
    }
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)fromMapView viewForAnnotation:(id <MKAnnotation>)annotation; {
  if ([annotation isKindOfClass:[MarkerPin class]]) {
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[fromMapView dequeueReusableAnnotationViewWithIdentifier:@"marker"];
    if(!annotationView) {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"marker"];
      annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    
    if ([((MarkerPin*)annotation).type isEqualToString:markerType[0]]) {
      annotationView.draggable = YES;
      annotationView.pinColor = MKPinAnnotationColorPurple;
    } else {
      if ([((MarkerPin*)annotation).type isEqualToString:markerType[1]]) {
        annotationView.pinColor = MKPinAnnotationColorGreen;
      } else {
        annotationView.pinColor = MKPinAnnotationColorRed;
      }
    }
    return annotationView;
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control; {
  // Go to edit view
  // if ([[((MarkerPin*)view.annotation) type] isEqualToString:markerType[0]]) {
  _tappedPin = view.annotation;
  [self performSegueWithIdentifier:@"CreateMarkerViewController" sender:self];
  // }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender; {
  if ([[segue identifier] isEqualToString:@"CreateMarkerViewController"])
  {
    // Get reference to the destination view controller
    CreateMarkerViewController *vc = [segue destinationViewController];

    if([_pinsOnMap objectForKey:_tappedPin.markerID]){
      vc.marker = ((MarkerPin *)[_pinsOnMap objectForKey:_tappedPin.markerID]).marker;
    }
    else{
      [[_mapView viewForAnnotation:_tappedPin] setHidden:YES];
      vc.createLocation = _tappedPin.coordinate;
    }
  }
}

- (void)deletePin:(NSString *)mid; {
  MarkerPin * pin = [_pinsOnMap objectForKey:mid];
  [_pinsOnMap removeObjectForKey:mid];
  [_mapView removeAnnotation:pin];
  _highlightPin = mid;
}

#pragma mark - ServerControllerDelegate Methods

- (void)serverController:(ServerController *)serverController didGetMarkers:(NSArray *)aMarkers; {
  for(MarkerPin * markerPin in _pinsOnMap.allValues){
    if(![aMarkers containsObject:markerPin.marker]){
      [self deletePin:markerPin.markerID];
    }
  }
  
  for (Marker *marker in aMarkers) {
    if ([_pinsOnMap objectForKey:marker.markerID] == nil ) {
      MarkerPin * point = [[MarkerPin  alloc] init];
      point.coordinate = CLLocationCoordinate2DMake([marker.latitude doubleValue], [marker.longitude doubleValue]);
      point.title = marker.title;
      point.subtitle = marker.markerDescription;
      point.markerID = marker.markerID;
      point.type = marker.type;
      point.marker = marker;
      [_mapView addAnnotation:point];
      for (int i = 1; i < 5; i++) {
        if ([point.type isEqualToString:markerType[i]]) {
          if (showType[i] == YES) {
            [[_mapView viewForAnnotation:point] setHidden:NO];
          } else {
            [[_mapView viewForAnnotation:point] setHidden:YES];
          }
        }
      }
      
      [_pinsOnMap setObject:point forKey:marker.markerID];
      
      if (_highlightPin != nil && [marker.markerID isEqualToString:_highlightPin]) {
        [_mapView selectAnnotation:point animated:YES];
      }
    }
  }
}

@end
