//  AppDelegate.h

#import <UIKit/UIKit.h>

@class User;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  User * _currentUser;
}

@property (strong, nonatomic) UIWindow * window;
@property (nonatomic, retain) User     * currrentUser;

+ (AppDelegate *)appDelegate;

@end
