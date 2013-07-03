//
//  Filter.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-07-03.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subscription;

@interface Filter : NSManagedObject

@property (nonatomic, retain) NSNumber * filterID;
@property (nonatomic, retain) NSString * markerTypes;
@property (nonatomic, retain) Subscription *subscription;

@end
