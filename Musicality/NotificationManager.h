//
//  NotificationManager.h
//  Musicality
//
//  Created by Evan Lewis on 10/6/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import Foundation;

#import "Artist.h"

@interface NotificationManager : NSObject

+ (instancetype)sharedManager;

- (void)addArtistToList:(Artist *)artist;
- (void)removeArtist:(Artist *)artist;

- (void)determineNotificationItems;
- (void)clearNotificationItems;

- (NSMutableOrderedSet *)loadData;
- (void)saveChanges;

- (void)pushAlbumNotificationLater:(NSString *)artistName album:(Album *)album;

@property (nonatomic) NSMutableOrderedSet *artistSet;

@property (nonatomic) UILocalNotification *localNotification;

@end
