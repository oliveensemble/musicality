//
//  AppDelegate.m
//  Musicality
//
//  Created by Evan Lewis on 9/29/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;
@import Fabric;
@import Crashlytics;

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
  [Fabric with:@[[Crashlytics class]]];
  
  UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
  UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
  [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
  application.minimumBackgroundFetchInterval = UIApplicationBackgroundFetchIntervalMinimum;
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstRun"]) {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
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
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

@end
