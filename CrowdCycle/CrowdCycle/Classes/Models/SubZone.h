//
//  SubZone.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-07-03.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subscription;

@interface SubZone : NSManagedObject

@property (nonatomic, retain) NSNumber * subZoneID;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Subscription *subscription;

@end
