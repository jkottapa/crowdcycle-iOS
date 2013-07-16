//  AppDelegate.h

#import <UIKit/UIKit.h>

@class User;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  id     _client;
  User * _currentUser;
}

@property (strong, nonatomic) UIWindow * window;
@property (nonatomic, retain) User     * currrentUser;
@property (nonatomic, retain) id         client;

+ (AppDelegate *)appDelegate;

@end
