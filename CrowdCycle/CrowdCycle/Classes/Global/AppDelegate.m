//  AppDelegate.m

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize currrentUser = _currentUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions; {
  return YES;
}

#pragma mark - Class Methods

+ (AppDelegate *)appDelegate; {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end