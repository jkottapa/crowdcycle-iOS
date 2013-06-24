//
//  User.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-06-24.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Marker, Subscription;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSDate * dateJoined;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *markers;
@property (nonatomic, retain) NSSet *subscriptions;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addMarkersObject:(Marker *)value;
- (void)removeMarkersObject:(Marker *)value;
- (void)addMarkers:(NSSet *)values;
- (void)removeMarkers:(NSSet *)values;

- (void)addSubscriptionsObject:(Subscription *)value;
- (void)removeSubscriptionsObject:(Subscription *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

@end
