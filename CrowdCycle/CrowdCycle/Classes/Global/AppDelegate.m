//  AppDelegate.m

#import "AppDelegate.h"
#import <libPusher/PTPusher.h>

@implementation AppDelegate

@synthesize client = _client;
@synthesize currrentUser = _currentUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions; {
  _client = [PTPusher pusherWithKey:@"e01b8b152934f9be5396" delegate:nil encrypted:YES];
  
  return YES;
}

#pragma mark - Class Methods

+ (AppDelegate *)appDelegate; {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end