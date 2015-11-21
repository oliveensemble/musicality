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
#import "AutoScan.h"
#import "Artist.h"
#import "MStore.h"

@interface AppDelegate () <UIAlertViewDelegate, SKStoreProductViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  // Override point for customization after application launch.
  
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
  
  return YES;
}

- (void)checkRequests {
  //As of now all this will do is check if a user has added artists to their library by checking the artist count
  if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
    NSUInteger num = mStore.artistsFromUserLibrary.count;
    NSUInteger lastLibraryNum = [[UserPrefs sharedPrefs] lastLibraryCount];
    if (num != lastLibraryNum) {
      DLog(@"number does not match");
      [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
      [[UserPrefs sharedPrefs] setLastLibraryCount:lastLibraryNum];
    }
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[NotificationList sharedList] clearNotificationItems];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  //DLog(@"Background Fetch");
  //[self checkRequests];
  //completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidReceiveNotification" object:nil userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidReceiveNotification" object:nil userInfo:notification.userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [[UserPrefs sharedPrefs] savePrefs];
  [[ArtistList sharedList] saveChanges];
  [[Blacklist sharedList] saveChanges];
}

@end
