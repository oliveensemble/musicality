//
//  NotificationCheck.h
//  Musicality
//
//  Created by Evan Lewis on 5/29/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"

@protocol NotificationCheckDelegate;

//Checks all items in the NotificationData plist and alerts user if artist has released music. It then removes that artist from the list
@interface NotificationCheck : NSOperation

@property (nonatomic, weak) id<NotificationCheckDelegate> delegate;
@property (nonatomic, strong) Artist *artist;
@property BOOL artistNeedsUpdating;

- (instancetype)initWithArtist:(Artist*)artist delegate:(id<NotificationCheckDelegate>) delegate;

@end

@protocol NotificationCheckDelegate <NSObject>

- (void)notificationCheckDidFinish:(NotificationCheck *)downloader;

@end