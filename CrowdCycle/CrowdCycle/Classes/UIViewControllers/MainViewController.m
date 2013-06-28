//
//  MainViewController.m
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import "MainViewController.h"

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
    [mapView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)profileButtonTapped:(id)sender; {
    [self performSegueWithIdentifier:@"LoginViewController" sender:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation; {
    self.currentLocation = newLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([newLocation coordinate], 1000, 1000);
    [mapView setRegion:region animated:YES];
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
    if (createPin == nil) {
        createPin = [[MKPointAnnotation  alloc] init];
        createPin.coordinate = self.currentLocation.coordinate;
        createPin.title = createPinTitle;
        createPin.subtitle = @"drag pin to desired location";
        [mapView addAnnotation:createPin];
        [mapView selectAnnotation:createPin animated:YES];
    } else {
        createPin.coordinate = self.currentLocation.coordinate;
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
@end
