//
//  AppDelegate.m
//  Musicality
//
//  Created by Elle Lewis on 9/29/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

@import StoreKit;

#import "NotificationManager.h"
#import "AppDelegate.h"
#import "ArtistList.h"
#import "Blacklist.h"
#import "UserPrefs.h"
#import "Artist.h"
#import "MStore.h"

@interface AppDelegate () <UIAlertViewDelegate, SKStoreProductViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
  application.minimumBackgroundFetchInterval = UIApplicationBackgroundFetchIntervalMinimum;
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstRun"]) {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
    UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
    [self.window setRootViewController:initialViewController];
  }
  
  // If the application was woken by a notification, store it
  UILocalNotification *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
  if (notification) {
    DLog(@"Setting notification");
    [[NotificationManager sharedManager] setLocalNotification:notification];
  }
  
  // Checks if any pre orders were released
  [[NotificationManager sharedManager] determineNotificationItems];
  
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  application.applicationIconBadgeNumber = 0;
  [[NotificationManager sharedManager] clearNotificationItems];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  if ([application applicationState] == UIApplicationStateInactive) {
    DLog(@"Setting notification");
    [[NotificationManager sharedManager] setLocalNotification:notification];
  } else {
    DLog(@"Received notification while application is running");
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self save];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [self save];
}

- (void)save {
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

@end
