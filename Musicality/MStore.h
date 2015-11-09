//
//  MStore.h
//  Musicality
//
//  Created by Evan Lewis on 9/29/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
@import Foundation;
#define mStore [MStore sharedStore]

#ifdef DEBUG
#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLog(...)
#endif

@interface MStore : NSObject

@property (nonatomic) NSDate *lastLibraryScanDate;
@property (nonatomic, readonly) NSString* affiliateToken;


+ (instancetype)sharedStore;

- (NSString*)formattedAlbumIDFromURL:(NSURL*)url;

- (NSDate*)formattedDateFromString:(NSString*)unFormattedDate;
- (BOOL)thisDate:(NSDate*)date1 isMoreRecentThan:(NSDate*)date2;
- (BOOL)isSameDay:(NSDate*)date1 as:(NSDate*)date2;
- (BOOL)isToday:(NSDate *)date;

- (NSArray*)artistsFromUserLibrary;

- (UIImage*)imageWithColor:(UIColor *)color;

- (void)showAlertPromptWithText:(NSString*)text;

@end