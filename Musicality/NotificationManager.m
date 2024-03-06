//
//  NotificationManager.m
//  Musicality
//
//  Created by Elle Lewis on 10/6/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

#import "MStore.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "NotificationManager.h"

@interface NotificationManager ()

@property (copy, nonatomic) NSString *path;
@property (nonatomic, retain) NSMutableArray *notifArray;

@end

@implementation NotificationManager

+ (instancetype)sharedManager {
  static NotificationManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] initPrivate];
  });
  return sharedManager;
}

- (instancetype)initPrivate {
  self = [super init];
  if (self) {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    _path = [documentsDirectory stringByAppendingPathComponent:@"NotificationData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: self.path]) {
      NSString *bundle = [[NSBundle mainBundle] pathForResource:@"NotificationData" ofType:@"plist"];
      [fileManager copyItemAtPath:bundle toPath: self.path error:&error];
    }
    //[self loadData];
  }
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"Use sharedList instead"
                               userInfo:nil];
  return nil;
}

- (void)addArtistToList:(Artist *)artist {
  if (artist.artistID) {
    //Check if artist is in the set
    for (Artist *listArtist in self.artistSet) {
      if (listArtist.artistID == artist.artistID) {
        return;
      }
    }
    [self.artistSet addObject:artist];
  }
}

- (void)removeArtist:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if (listArtist.artistID == artist.artistID) {
      [self.artistSet removeObject:listArtist];
      return;
    }
  }
}

- (void)determineNotificationItems {
  BOOL artistListChanged = false;
  for (Artist *artist in [[ArtistList sharedList] artistSet]) {
    if (artist.latestRelease.isPreOrder) {
      //If the pre order was finally released
      if ([mStore isToday:artist.latestRelease.releaseDate] || [mStore thisDate:[NSDate date] isMoreRecentThan:artist.latestRelease.releaseDate]) {
        artistListChanged = YES;
        artist.latestRelease.isPreOrder = NO;
      } else {
        [self pushAlbumNotificationLater:artist.name album:artist.latestRelease];
      }
    }
  }
  if (artistListChanged) {
    [[ArtistList sharedList] saveChanges];
  }
}

- (void)clearNotificationItems {
  for (UILocalNotification *localNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
    if ([mStore thisDate:[NSDate date] isMoreRecentThan:localNotif.fireDate]) {
      [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
    }
  }
}

- (void)pushAlbumNotificationLater:(NSString*)artistName album:(Album*)album {
  
  //Start by getting day of NSDate
  NSCalendar *calendar = [NSCalendar currentCalendar];
  calendar.timeZone = [NSTimeZone localTimeZone];
  NSDate *fireDate = [calendar dateBySettingHour:12 minute:0 second:0 ofDate:album.releaseDate options:0];
  
  if (!self.notifArray) {
    _notifArray = [NSMutableArray arrayWithArray:[[UIApplication sharedApplication] scheduledLocalNotifications]];
  }
  
  NSString *alertBody = [NSString stringWithFormat:@"%@ releases %@", artistName, album.title];
  for (UILocalNotification *notif in self.notifArray) {
    
    if ([notif.alertBody containsString:album.title]) {
      // If we already scheduled the notification, don't do it again
      return;
    }
    
    if ([mStore isSameDay:fireDate as:notif.fireDate]) {
      NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:notif.fireDate];
      NSInteger hour = [components hour];
      if (hour >= 22 || hour < 8) {
        fireDate = [calendar dateBySettingHour:8 minute:0 second:0 ofDate:album.releaseDate options:0];
      } else {
        fireDate = [calendar dateBySettingHour:hour + 2 minute:0 second:0 ofDate:album.releaseDate options:0];
      }
    }
  }
  
  UILocalNotification *localNotif = [[UILocalNotification alloc] init];
  localNotif.alertAction = NSLocalizedString(@"Check it out", nil);
  localNotif.soundName = UILocalNotificationDefaultSoundName;
  localNotif.applicationIconBadgeNumber += 1;
  localNotif.timeZone = [NSTimeZone defaultTimeZone];
  localNotif.fireDate = fireDate;
  localNotif.alertBody = alertBody;
  
  if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
    [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
  }
  
  localNotif.userInfo = @{@"albumID" : [mStore formattedAlbumIDFromURL:album.URL], @"artistName" : artistName};
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
  [self.notifArray addObject:localNotif];
  DLog(@"Setting notification later for %@ albumName: %@ date: %@", artistName, album.title, fireDate);
  
}

- (NSMutableOrderedSet*)loadData {
  NSData *archiveData = [NSData dataWithContentsOfFile:self.path];
  self.artistSet = nil;
  @try {
    _artistSet = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
  }
  @catch (NSException *exception) {
    _artistSet = [[NSMutableOrderedSet alloc] init];
  }
  return self.artistSet;
}

- (void)saveChanges {
  DLog(@"Saving notification list changes");
  NSError *error;
  NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.artistSet];
  [archiveData writeToFile:self.path atomically:YES];
  if (error) {
    DLog(@"Error: %@", [error localizedDescription]);
  }
}

@end
