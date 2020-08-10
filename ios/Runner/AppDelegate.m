#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString* mapsApiKey = [[NSProcessInfo processInfo] environment][@"MAPS_API_KEY"];
  if ([mapsApiKey length] == 0) {
    mapsApiKey = @"AIzaSyC__CkJYkrV1QhAOFhVlMgiH76rz3QH_Ok"; // TODO: Remove this
  }

  [GMSServices provideAPIKey:mapsApiKey];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
