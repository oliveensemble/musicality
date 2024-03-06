//
//  Artist.m
//  Musicality
//
//  Created by Elle Lewis on 9/30/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

#import "Artist.h"

@interface Artist ()

@property (nonatomic) NSURLSession *session;

@end

@implementation Artist

- (instancetype)initWithArtistID:(NSString*)artistID andName:(NSString*)artistName {
  self = [super init];
  if (self) {
    _artistID = [NSNumber numberWithLong:artistID.intValue];
    _name = artistName;
    _latestRelease = nil;
    _lastCheckDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _artistID = [aDecoder decodeObjectForKey:@"artistID"];
    _name = [aDecoder decodeObjectForKey:@"artistName"];
    _latestRelease = [aDecoder decodeObjectForKey:@"latestRelease"];
    _lastCheckDate = [aDecoder decodeObjectForKey:@"lastCheckDate"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.artistID forKey:@"artistID"];
  [aCoder encodeObject:self.name forKey:@"artistName"];
  [aCoder encodeObject:self.latestRelease forKey:@"latestRelease"];
  [aCoder encodeObject:self.lastCheckDate forKey:@"lastCheckDate"];
}

- (void)addArtistId:(NSString*)artistID {
  self.artistID = [NSNumber numberWithLong:artistID.intValue];
}

- (BOOL)isEqualToArtist:(Artist*)artist {
  if (!artist) {
    return NO;
  }
  
  BOOL haveEqualNames = (!self.name && !artist.name) || [[self.name lowercaseString] isEqualToString:[artist.name lowercaseString]];
  BOOL haveEqualArtistIds = (!self.artistID && !artist.artistID) || self.artistID == artist.artistID;
  
  return haveEqualNames && haveEqualArtistIds;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"\nArtist: %@\nID: %@", self.name, self.artistID];
}

@end
