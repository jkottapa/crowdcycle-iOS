//
//  BoxSubZone.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-07-03.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SubZone.h"


@interface BoxSubZone : SubZone

@property (nonatomic, retain) NSNumber * bottomRightLatitude;
@property (nonatomic, retain) NSNumber * bottomRightLongitude;
@property (nonatomic, retain) NSNumber * topLeftLatitude;
@property (nonatomic, retain) NSNumber * topLeftLongitude;

@end
