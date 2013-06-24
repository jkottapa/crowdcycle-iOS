//
//  Subscription.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-06-24.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Filter, SubZone, User;

@interface Subscription : NSManagedObject

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSNumber * subscriptionID;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) Filter *filter;
@property (nonatomic, retain) SubZone *subZone;

@end
