//
//  UserPrefs.m
//  Musicality
//
//  Created by Elle Lewis on 6/23/15.
//  Copyright (c) 2015 Later Creative LLC. All rights reserved.
//

#import "UserPrefs.h"

@implementation UserPrefs

static NSString* const MArtistListNeedsUpdatingKey = @"artistListNeedsUpdating";
static NSString* const MLastLibraryCountKey = @"lastLibraryCount";
static NSString* const MIsAutoUpdateEnabledKey = @"isAutoUpdateEnabled";
static NSString* const MIsDarkModeEnabledKey = @"isDarkModeEnabled";
static NSString* const MIsAppleMusicEnabledKey = @"isAppleMusicEnabled";

static NSString* const MNoArtistsKey = @"noArtists";

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.artistListNeedsUpdating forKey:MArtistListNeedsUpdatingKey];
    [aCoder encodeInteger:self.lastLibraryCount forKey:MLastLibraryCountKey];
    [aCoder encodeBool:self.isAutoUpdateEnabled forKey:MIsAutoUpdateEnabledKey];
    [aCoder encodeBool:self.isDarkModeEnabled forKey:MIsDarkModeEnabledKey];
    [aCoder encodeBool:self.isAppleMusicEnabled forKey:MIsAppleMusicEnabledKey];
    [aCoder encodeBool:self.noArtists forKey:MNoArtistsKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        _artistListNeedsUpdating = [aDecoder decodeBoolForKey:MArtistListNeedsUpdatingKey];
        _lastLibraryCount = [aDecoder decodeIntegerForKey:MLastLibraryCountKey];
        _isAutoUpdateEnabled = [aDecoder decodeBoolForKey:MIsAutoUpdateEnabledKey];
        _isDarkModeEnabled = [aDecoder decodeBoolForKey: MIsDarkModeEnabledKey];
        _isAppleMusicEnabled = [aDecoder decodeBoolForKey:MIsAppleMusicEnabledKey];
        _noArtists = [aDecoder decodeBoolForKey:MNoArtistsKey];
    }
    return self;
}

+ (instancetype)sharedPrefs {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });

    return sharedInstance;
}

+ (NSString*)filePath {
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"userPrefs"];
    }
    return filePath;
}

+ (instancetype)loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [UserPrefs filePath]];
    if (decodedData) {
        UserPrefs* userPrefs = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return userPrefs;
    }
    return [[UserPrefs alloc] init];
}

- (void)savePrefs {
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[UserPrefs filePath] atomically:YES];
}

@end
