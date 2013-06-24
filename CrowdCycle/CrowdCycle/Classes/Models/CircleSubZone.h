//
//  CircleSubZone.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-06-24.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SubZone.h"


@interface CircleSubZone : SubZone

@property (nonatomic, retain) NSNumber * pointLatitude;
@property (nonatomic, retain) NSNumber * pointLongitude;
@property (nonatomic, retain) NSNumber * radius;

@end
