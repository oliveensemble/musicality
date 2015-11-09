//
//  NotificationListHandler.m
//  Musicality
//
//  Created by Evan Lewis on 11/3/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "NotificationListHandler.h"
#import "NotificationCheck.h"
#import "NotificationList.h"
#import "AppDelegate.h"
#import "MStore.h"
#import "Artist.h"

@interface NotificationListHandler ()

@property (nonatomic) NSMutableArray *localNotificationArray;

@end

@implementation NotificationListHandler

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)startRequests {
  NSMutableOrderedSet *artistSet = [[NotificationList sharedList] artistSet];
  if (artistSet.count != 0) {
    DLog(@"Checking requests");
    for (Artist* artist in artistSet) {
      NotificationCheck *notificationCheck = [[NotificationCheck alloc] initWithArtist:artist delegate:self];
      DLog(@"Search in progress");
      [self.pendingOperations.searchesInProgress setObject:notificationCheck forKey:[NSString stringWithFormat:@"Notification Check for %@", artist.name]];
      [self.pendingOperations.searchQueue addOperation:notificationCheck];
    }
  } else {
    DLog(@"Nothing to check");
  }
}

- (void)notificationCheckDidFinish:(NotificationCheck *)downloader {
  [self.pendingOperations.searchesInProgress removeObjectForKey:[NSString stringWithFormat:@"Notification Check for %@", downloader.artist.name]];
  DLog(@"Recieved a notification");
  if (self.pendingOperations.searchesInProgress.count == 0) {
    DLog(@"Finished searching");
    return;
  }
  if (!downloader.artistNeedsUpdating) {
    DLog(@"Artist doesn't need updating");
    return;
  } else {
    DLog(@"Found item");
    [self pushAlbumNotificationNow:downloader.artist.name albumTitle:downloader.artist.latestRelease.title];
    [[NotificationList sharedList] removeArtist:downloader.artist];
  }
}

- (void)pushAlbumNotificationNow:(NSString*)artistName albumTitle:(NSString*)albumTitle {
  
  NSMutableArray *nonPreOrderNotifs = [NSMutableArray array];
  for (UILocalNotification *localNofif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
    //Make sure you're not checking a pre order item
    if ([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:120] isMoreRecentThan:localNofif.fireDate]) {
      [nonPreOrderNotifs addObject:localNofif];
    }
  }
  
  UILocalNotification *localNotif = [[UILocalNotification alloc] init];
  localNotif.alertAction = NSLocalizedString(@"Check it out", nil);
  localNotif.soundName = UILocalNotificationDefaultSoundName;
  localNotif.applicationIconBadgeNumber += 1;
  localNotif.timeZone = [NSTimeZone defaultTimeZone];
  localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
  
  if (nonPreOrderNotifs.count != 0) {
    //If there is already a notification scheduled, create a group one
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    localNotif.alertBody = [NSString stringWithFormat:@"New releases by %@ and more", artistName];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    DLog(@"Setting notification for multiple artists");
    return;
  }
  
  localNotif.alertBody = [NSString stringWithFormat:@"%@ releases %@", artistName, albumTitle];
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
  DLog(@"Setting notification for %@", artistName);
  
}

@end
