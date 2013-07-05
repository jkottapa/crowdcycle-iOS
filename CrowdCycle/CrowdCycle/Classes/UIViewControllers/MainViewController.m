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

@interface MainViewController ()

@end

static NSString * const createPinTitle = @"Create new marker";

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

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  [locationManager startMonitoringSignificantLocationChanges];
  [_mapView setDelegate:self];
  [[ServerController sharedServerController] getMarkersWithDelegate:self];
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

- (void)dropPinButtonTapped:(id)sender; {
  if (_createPin == nil) {
    _createPin = [[MKPointAnnotation  alloc] init];
    _createPin.coordinate = _mapView.centerCoordinate;
    _createPin.title = createPinTitle;
    _createPin.subtitle = @"drag pin to desired location";
    [_mapView addAnnotation:_createPin];
    [_mapView selectAnnotation:_createPin animated:YES];
  } else {
    _createPin.coordinate = _mapView.centerCoordinate;
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)fromMapView viewForAnnotation:(id <MKAnnotation>)annotation; {
  if ([[annotation title] isEqualToString:createPinTitle]) {
    MKAnnotationView *annotationView = [fromMapView dequeueReusableAnnotationViewWithIdentifier:@"marker"];
    if(!annotationView) {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"marker"];
      annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    
    return annotationView;
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control; {
  // Go to edit view
  if ([[view.annotation title] isEqualToString:createPinTitle]) {
    [self performSegueWithIdentifier:@"CreateMarkerViewController" sender:self];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender; {
    if ([[segue identifier] isEqualToString:@"CreateMarkerViewController"])
    {
        // Get reference to the destination view controller
        CreateMarkerViewController *vc = [segue destinationViewController];
        vc.createLocation = _createPin.coordinate;
    }
}
@end
