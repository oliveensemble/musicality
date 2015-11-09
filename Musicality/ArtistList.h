//
//  ArtistList.h
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"

@interface ArtistList : NSObject

+ (instancetype)sharedList;

- (void)addArtistToList:(Artist*)artist;
- (void)removeArtist:(Artist*)artist;
- (void)updateLatestRelease:(Album*)album forArtist:(Artist *)artist;
- (void)removeAllArtists;

- (void)saveChanges;

//Checks by name if artist is in list
- (BOOL)isInList:(Artist *)artist;
- (Artist *)getArtist:(NSString *)artistName;

@property (nonatomic) NSMutableOrderedSet* artistSet;

@end
