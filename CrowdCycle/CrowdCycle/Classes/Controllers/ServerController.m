//  ServerController.m

#import "ServerController.h"
#import "User.h"
#import "Marker.h"
#import "Comment.h"
#import "SynthesizeSingleton.h"

@interface ServerController (Private)

- (void)configureRestKit;

@end

@implementation ServerController

@synthesize managedObjectContext = _managedObjectContext;

SYNTHESIZE_SINGLETON_FOR_CLASS(ServerController)

#pragma mark - Init

- (id)init; {
  if((self = [super init])){
    [self configureRestKit];
  }
  return self;
}

#pragma mark - Methods

- (void)deleteUser:(User *)aUser delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aUser
                        path:[NSString stringWithFormat:@"users/delete/%@", aUser.userID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)getUserDetails:(User *)aUser delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"users/details/%@", aUser.userID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)editUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aUser
                        path:[NSString stringWithFormat:@"users/edit/%@", aUser.userID]
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:aPassword, @"PSWD", nil]
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)createUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aUser
                        path:@"users/create"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:aPassword, @"PSWD", nil]
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                       
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didCreateUser:)]){
                         [aDelegate serverController:self didCreateUser:mappingResult.firstObject];
                       }
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)getMarkersWithDelegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager getObjectsAtPath:@"markers/list"
                        parameters:nil
                           success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                             NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                           }
                           failure:^(RKObjectRequestOperation * operation, NSError * error) {
                             NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                           }];
}

- (void)editMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aMarker
                        path:[NSString stringWithFormat:@"markers/edit/%@", aMarker.markerID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)createMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aMarker
                        path:@"markers/create"
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)deleteMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aMarker
                        path:[NSString stringWithFormat:@"markers/delete/%@", aMarker.markerID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)getMarkerDetails:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"markers/detail/%@", aMarker.markerID]
                        parameters:nil
                           success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                             NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                           }
                           failure:^(RKObjectRequestOperation * operation, NSError * error) {
                             NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                           }];
}

- (void)deleteComment:(Comment *)aComment delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aComment
                        path:[NSString stringWithFormat:@"comments/delete/%@", aComment.commentID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)getCommentsForMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager getObjectsAtPath:[NSString stringWithFormat:@"comments/list/%@", aMarker.markerID]
                        parameters:nil
                           success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                             NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                           }
                           failure:^(RKObjectRequestOperation * operation, NSError * error) {
                             NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                           }];
}

- (void)createComment:(Comment *)aComment forMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aComment
                        path:[NSString stringWithFormat:@"comments/create/%@", aMarker.markerID]
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

@end

@implementation ServerController (Private)

- (void)configureRestKit; {
  NSError * error;
  NSURL * modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CoreData" ofType:@"momd"]];
  NSManagedObjectModel * managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
  RKManagedObjectStore * managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
  
  [managedObjectStore createPersistentStoreCoordinator];
  
  NSArray * searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString * documentPath = [searchPaths objectAtIndex:0];
  NSPersistentStore * persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:[NSString stringWithFormat:@"%@/CoreData.sqlite", documentPath] fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
  
  if(!persistentStore){
    NSLog(@"Failed to add persistent store: %@", error);
  }
  
  [managedObjectStore createManagedObjectContexts];
  
  [RKManagedObjectStore setDefaultStore:managedObjectStore];
  
  _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://crowdcycle.herokuapp.com/"]];
  _objectManager.managedObjectStore = managedObjectStore;
  _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
  _managedObjectContext = _objectManager.managedObjectStore.mainQueueManagedObjectContext;
  
  RKEntityMapping * userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
  [userMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateJoined", @"dateJoined", @"name", @"name", @"email", @"email", @"userID", @"uid", nil]];
  userMapping.identificationAttributes = [NSArray arrayWithObjects:@"userID", nil];
  
  RKEntityMapping * markerMapping = [RKEntityMapping mappingForEntityForName:@"Marker" inManagedObjectStore:managedObjectStore];
  [markerMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateCreated", @"dateCreated", @"dateModified", @"dateModified", @"downVotes", @"downVotes", @"upVotes", @"upVotes", @"latitude", @"latitude", @"longitude", @"longitude", @"markerDescription", @"markerDescription", @"markerID", @"markerID", @"title", @"title", @"type", @"type", nil]];
  markerMapping.identificationAttributes = [NSArray arrayWithObjects:@"markerID", nil];
  
  RKObjectMapping * userSerialMapping = [RKObjectMapping requestMapping];
  [userSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"UNAME", @"name", @"EMAIL", @"email", nil]];
  
  RKObjectMapping * markerSerialMapping = [RKObjectMapping requestMapping];
  [markerSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"LAT", @"latitude", @"LON", @"longitude", @"MARKERTYPE", @"type", @"TITLE", @"title", @"DESCRIPTION", @"markerDescription", nil]];
  
  RKObjectMapping * commentSerialMapping = [RKObjectMapping requestMapping];
  [commentSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"TEXT", @"text", nil]];
  
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:markerSerialMapping objectClass:[Marker class] rootKeyPath:nil]];
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userSerialMapping objectClass:[User class] rootKeyPath:nil]];
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:commentSerialMapping objectClass:[Comment class] rootKeyPath:nil]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/create" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/detail/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/edit/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/list" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/delete/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/vote/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/create" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/details/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/edit/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/list" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/delete/:id" keyPath:@"result.msg.rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
}

@end