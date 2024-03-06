//
//  UserPrefs.h
//  Musicality
//
//  Created by Elle Lewis on 6/23/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

@import Foundation;

@interface UserPrefs : NSObject <NSCoding>

+ (instancetype)sharedPrefs;
- (void)savePrefs;

@property (nonatomic, assign) BOOL artistListNeedsUpdating;
@property (nonatomic, assign) BOOL isAutoUpdateEnabled;
@property (nonatomic, assign) BOOL isDarkModeEnabled;
@property (nonatomic, assign) BOOL isAppleMusicEnabled;
@property (nonatomic, assign) BOOL noArtists;

@property (nonatomic, assign) NSUInteger lastLibraryCount;

@end
