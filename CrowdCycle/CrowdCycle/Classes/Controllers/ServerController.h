//  ServerController.h

#import <RestKit/RestKit.h>
#import <Foundation/Foundation.h>

@class User;
@class ServerController;

@protocol ServerControllerDelegate

@optional
- (void)serverController:(ServerController *)serverController didCreateUser:(User *)aUser;

@end

@interface ServerController : NSObject {
  NSManagedObjectContext * _managedObjectContext;
  RKObjectManager        * _objectManager;
}

@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

+ (ServerController *)sharedServerController;

- (void)createUser:(User *)aUser withPassword:(NSString *)aPassword delegate:(id<ServerControllerDelegate>)aDelegate;

@end
