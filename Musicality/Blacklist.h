//
//  Blacklist.h
//  Musicality
//
//  Created by Elle Lewis on 6/19/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

@import Foundation;

#import "Artist.h"

@interface Blacklist : NSObject

+ (instancetype)sharedList;

- (BOOL)isInList:(Artist *)artist;

- (void)addArtistToList:(Artist *)artist;
- (void)removeArtist:(Artist *)artist;
- (void)removeAllArtists;

- (void)saveChanges;

@end
