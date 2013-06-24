//
//  Marker.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-06-24.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, User;

@interface Marker : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * upVotes;
@property (nonatomic, retain) NSNumber * downVotes;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * markerDescription;
@property (nonatomic, retain) NSNumber * markerID;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *owner;
@end

@interface Marker (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
