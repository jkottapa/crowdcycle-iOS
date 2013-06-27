//  ServerController.m

#import "ServerController.h"
#import "User.h"
#import "Marker.h"
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

- (void)createUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate; {
  [_objectManager postObject:aUser
                        path:@"users/create"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:aPassword, @"PSWD", nil]
                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult) {
                       NSLog(@"Success: %@", operation.HTTPRequestOperation.responseString);
                     }
                     failure:^(RKObjectRequestOperation * operation, NSError * error) {
                       NSLog(@"Failure: %@", operation.HTTPRequestOperation.responseString);
                     }];
  
// Add it to the appropriate controller later
//  ServerController * serverController = [ServerController sharedServerController];
//  User * user = (User *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:serverController.managedObjectContext] insertIntoManagedObjectContext:serverController.managedObjectContext];
//  user.email = @"test@test.ca";
//  user.name = @"Test User";
//  [serverController createUser:user withPassword:@"testing123" delegate:self];
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
  [userMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateJoined", @"dateJoined", @"name", @"name", @"email", @"email", @"userID", @"userID", nil]];
  userMapping.identificationAttributes = [NSArray arrayWithObjects:@"userID", nil];
  
  RKEntityMapping * markerMapping = [RKEntityMapping mappingForEntityForName:@"Marker" inManagedObjectStore:managedObjectStore];
  [markerMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"dateCreated", @"dateCreated", @"dateModified", @"dateModified", @"downVotes", @"downVotes", @"upVotes", @"upVotes", @"latitude", @"latitude", @"longitude", @"longitude", @"markerDescription", @"markerDescription", @"markerID", @"markerID", @"title", @"title", @"type", @"type", nil]];
  markerMapping.identificationAttributes = [NSArray arrayWithObjects:@"markerID", nil];
  
  RKObjectMapping * userSerialMapping = [RKObjectMapping requestMapping];
  [userSerialMapping addAttributeMappingsFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"UNAME", @"name", @"EMAIL", @"email", nil]];
  
  RKObjectMapping * markerSerialMapping = [markerMapping inverseMapping];
  
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:markerSerialMapping objectClass:[Marker class] rootKeyPath:nil]];
  [_objectManager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:userSerialMapping objectClass:[User class] rootKeyPath:nil]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/create" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/detail/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/edit/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/list" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/delete/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"markers/vote/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:userMapping pathPattern:@"users/create" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/details/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/edit/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/list" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
  [_objectManager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:markerMapping pathPattern:@"users/delete/:id" keyPath:@"rows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
}

@end