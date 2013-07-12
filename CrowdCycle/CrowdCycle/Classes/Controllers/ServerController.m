//  ServerController.m

#import "ServerController.h"
#import "User.h"
#import "Marker.h"
#import "Comment.h"
#import "SynthesizeSingleton.h"

@interface ServerController (Private)

- (void)configureRestKit;
- (NSArray *)fetchLocalObjectsOfClass:(NSString *)aClass searchPredicate:(NSPredicate *)aPredicate;

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
  [_objectManager getObject:aUser
                       path:[NSString stringWithFormat:@"users/details/%@", aUser.userID]
                        parameters:nil
                           success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                             NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                             if([(id)aDelegate respondsToSelector:@selector(serverController:didGetUserDetails:)]){
                               NSArray * array = [self fetchLocalObjectsOfClass:@"User" searchPredicate:[NSPredicate predicateWithFormat:@"userID = %@", ((User *)[mappingResult firstObject]).userID]];
                               [aDelegate serverController:self didGetUserDetails:[array objectAtIndex:0]];
                             }
                           }
                           failure:^(RKObjectRequestOperation * operation, NSError * error) {
                             NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                           }];
}

- (void)editUser:(User *)aUser withPassword:(NSString *)aPassword newPassword:(NSString *) aNewPassword newName:(NSString *)aNewName delegate:(id<ServerControllerDelegate>)aDelegate; {
  NSMutableDictionary * mappings = [NSMutableDictionary dictionary];
  if (aNewPassword) {
    [mappings setObject:aNewPassword forKey:@"PSWD"];
  }
  if (aNewName) {
    [mappings setObject:aNewName forKey:@"UNAME"];
  }
  [_objectManager postObject:nil
                        path:[NSString stringWithFormat:@"users/edit/%@", aUser.userID]
                  parameters:mappings
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                       if (aNewName) {
                         aUser.name = aNewName;
                       }
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didEditUser:)]){
                         [aDelegate serverController:self didEditUser:aUser];
                       }
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
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didFailWithError:)]){
                         [aDelegate serverController:self didFailWithError:error];
                       }
                     }];
}

- (void)logout:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager getObject:nil
                        path:@"logout"
                  parameters:nil
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didLogout:)]){
                         [aDelegate serverController:self didLogout:YES];
                       }
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
}

- (void)loginWithEmail:(NSString *)aEmail password:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate; {
  User * user = (User *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:_managedObjectContext] insertIntoManagedObjectContext:_managedObjectContext];
  user.email = aEmail;
  [_objectManager postObject:user
                        path:@"login"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:aPassword, @"password", aEmail, @"user", nil]
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                       
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didCreateUser:)]){
                         NSArray * array = [self fetchLocalObjectsOfClass:@"User" searchPredicate:[NSPredicate predicateWithFormat:@"userID = %@", ((User *)[mappingResult firstObject]).userID]];
                         [aDelegate serverController:self didCreateUser:[array objectAtIndex:0]];
                       }
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                       if([(id)aDelegate respondsToSelector:@selector(serverController:didFailWithError:)]){
                         [aDelegate serverController:self didFailWithError:error];
                       }
                     }];
}

- (void)getMarkersWithDelegate:(id<ServerControllerDelegate>)aDelegate lat1:(NSNumber*)lat1 long1:(NSNumber*)long1 lat2:(NSNumber*)lat2 long2:(NSNumber*)long2; {
  [_objectManager getObjectsAtPath:@"markers/list"
                        parameters:[NSDictionary dictionaryWithObjectsAndKeys:lat1, @"LAT1", long1, @"LON1", lat2, @"LAT2", long2, @"LON2", nil]
                           success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                             if([(id)aDelegate respondsToSelector:@selector(serverController:didGetMarkers:)]){
                               [aDelegate serverController:self didGetMarkers:[mappingResult array]];
                             }
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
  
  //_objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000/"]];
  _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://crowdcycle.herokuapp.com/"]];
  _objectManager.managedObjectStore = managedObjectStore;
  _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
  _managedObjectContext = _objectManager.managedObjectStore.mainQueueManagedObjectContext;
  
  RKEntityMapping * userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
  [userMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateJoined", @"joined", @"name", @"uname", @"email", @"email", @"userID", @"uid", nil]];
  userMapping.identificationAttributes = [NSArray arrayWithObjects:@"userID", nil];
  
  RKEntityMapping * markerMapping = [RKEntityMapping mappingForEntityForName:@"Marker" inManagedObjectStore:managedObjectStore];
  [markerMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateCreated", @"created", @"dateModified", @"modified", @"downVotes", @"downvotes", @"upVotes", @"upvotes", @"latitude", @"latitude", @"longitude", @"longitude", @"markerDescription", @"description", @"markerID", @"uid", @"title", @"title", @"type", @"markertype", nil]];
  markerMapping.identificationAttributes = [NSArray arrayWithObjects:@"markerID", nil];
  
  RKObjectMapping * userSerialMapping = [RKObjectMapping requestMapping];
  [userSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"UNAME", @"name", @"EMAIL", @"email", nil]];
  
  RKObjectMapping * markerSerialMapping = [RKObjectMapping requestMapping];
  [markerSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"LAT", @"latitude", @"LON", @"longitude", @"MARKERTYPE", @"type", @"TITLE", @"title", @"DESCRIPTION", @"markerDescription", nil]];
  
  RKEntityMapping * commentMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:managedObjectStore];
  [commentMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"commentID", @"uid", nil]];
  
  RKObjectMapping * commentSerialMapping = [RKObjectMapping requestMapping];
  [commentSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"TEXT", @"text", nil]];
  
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:markerSerialMapping objectClass:[Marker class] rootKeyPath:nil]];
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userSerialMapping objectClass:[User class] rootKeyPath:nil]];
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:commentSerialMapping objectClass:[Comment class] rootKeyPath:nil]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/create" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/detail/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/edit/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/list" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/delete/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/vote/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"login" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"logout" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/create" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/details/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/edit/:id" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/list" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/delete/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:commentMapping pathPattern:@"comments/create/:id" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
}

- (NSArray *)fetchLocalObjectsOfClass:(NSString *)aClass searchPredicate:(NSPredicate *)aPredicate; {
  NSEntityDescription * entityDescription = [NSEntityDescription entityForName:aClass inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];
  
  NSPredicate * predicate = aPredicate;
  [request setPredicate:predicate];
  
  NSError * error;
  NSArray * array = [self.managedObjectContext executeFetchRequest:request error:&error];
  
  if(error){
    NSLog(@"Error occured when fetching objects from CoreData: %@", error);
  }
  return array;
}

@end