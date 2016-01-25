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

#import "NotificationListHandler.h"
#import "NotificationList.h"
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
  
  [[NotificationList sharedList] determineNotificationItems];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[NotificationList sharedList] clearNotificationItems];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  if([application applicationState] == UIApplicationStateInactive) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidReceiveNotification" object:nil userInfo:notification.userInfo];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

@end
