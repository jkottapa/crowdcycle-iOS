//
//  Filter.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-06-24.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subscription;

@interface Filter : NSManagedObject

@property (nonatomic, retain) NSString * markerTypes;
@property (nonatomic, retain) NSNumber * filterID;
@property (nonatomic, retain) Subscription *subscription;

@end
