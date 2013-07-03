//
//  Comment.h
//  CrowdCycle
//
//  Created by Daniel MacKenzie on 2013-07-03.
//  Copyright (c) 2013 Daniel MacKenzie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Marker, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * commentID;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Marker *marker;
@property (nonatomic, retain) User *user;

@end
