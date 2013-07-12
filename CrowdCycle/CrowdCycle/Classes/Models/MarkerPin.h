//
//  MarkerPin.h
//  CrowdCycle
//
//  Created by Yanwei Xiao on 7/6/13.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Marker.h"

@interface MarkerPin : MKPointAnnotation

@property (nonatomic, retain) Marker * marker;
@property (nonatomic, copy) NSString * markerID;
@property (nonatomic, copy) NSString * type;
@end
