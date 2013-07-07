//
//  MainViewController.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 6/23/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ServerController.h"
#import "MarkerPin.h"

@interface MainViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, ServerControllerDelegate>{
  IBOutlet MKMapView * _mapView;
  CLLocationManager * _locationManager;
  MarkerPin * _createPin;
  NSMutableDictionary * _pinsOnMap;
  BOOL userLocated;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (IBAction)profileButtonTapped:(id)sender;
- (IBAction)dropPinButtonTapped:(id)sender;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end