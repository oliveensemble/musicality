//
//  Artist.h
//  Musicality
//
//  Created by Elle Lewis on 9/30/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//
@import Foundation;

#import "Album.h"

//responsible for keeping track of the artists in the users music library
@interface Artist : NSObject <NSCoding>

@property (nonatomic) NSNumber *artistID;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) Album *latestRelease;
@property (nonatomic) NSDate *lastCheckDate;

- (instancetype)initWithArtistID:(NSString*)artistID andName:(NSString*)artistName;

- (void)addArtistId:(NSString*)artistID;
- (BOOL)isEqualToArtist:(Artist*)artist;

@end
