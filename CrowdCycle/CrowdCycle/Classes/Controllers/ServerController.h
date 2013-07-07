//  ServerController.h

#import <RestKit/RestKit.h>
#import <Foundation/Foundation.h>

@class User;
@class Marker;
@class Comment;
@class ServerController;

@protocol ServerControllerDelegate

@optional
- (void)serverController:(ServerController *)serverController didGetMarkers:(NSArray *)aMarkers;
- (void)serverController:(ServerController *)serverController didCreateUser:(User *)aUser;
- (void)serverController:(ServerController *)serverController didGetUserDetails:(User *)aUser;
- (void)serverController:(ServerController *)serverController didFailWithError:(NSError *)aError;

@end

@interface ServerController : NSObject {
  NSManagedObjectContext * _managedObjectContext;
  RKObjectManager        * _objectManager;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

+ (ServerController *)sharedServerController;

- (void)deleteUser:(User *)aUser delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)getUserDetails:(User *)aUser delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)editUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)createUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)loginWithEmail:(NSString *)aEmail password:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate;

- (void)getMarkersWithDelegate:(id<ServerControllerDelegate>)aDelegate lat1:(NSNumber*)lat1 long1:(NSNumber*)long1 lat2:(NSNumber*)lat2 long2:(NSNumber*)long2;
- (void)editMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)createMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)deleteMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)getMarkerDetails:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;

- (void)deleteComment:(Comment *)aComment delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)getCommentsForMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;
- (void)createComment:(Comment *)aComment forMarker:(Marker *)aMarker delegate:(id<ServerControllerDelegate>)aDelegate;

@end
