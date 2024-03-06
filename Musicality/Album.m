//
//  Album.m
//  Musicality
//
//  Created by Elle Lewis on 9/30/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

#import "Album.h"
#import "MStore.h"

@implementation Album

- (instancetype)initWithAlbumTitle:(NSString*)title artist:(NSString*)artist artworkURL:(NSString*)artWorkURL albumURL:(NSString *)url releaseDate:(NSString *)releaseDate {
  self = [super init];
  if (self) {
    _title = title;
    _artist = artist;
    _releaseDate = [mStore formattedDateFromString:releaseDate];
    if ([mStore thisDate:self.releaseDate isMoreRecentThan:[NSDate date]]) {
      self.isPreOrder = YES;
    } else {
      _isPreOrder = NO;
    }
    
    _URL = [NSURL URLWithString:url];
    
    if ([artWorkURL containsString:@"100x100"]) {
      _artworkURL = [NSURL URLWithString:[artWorkURL stringByReplacingOccurrencesOfString:@"100x100"withString:@"250x250"]];
    } else {
      _artworkURL = [NSURL URLWithString:[artWorkURL stringByReplacingOccurrencesOfString:@"170x170"withString:@"250x250"]];
    }
    
    _artistID = [NSNumber numberWithLong:0];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _title = [aDecoder decodeObjectForKey:@"albumTitle"];
    _artist = [aDecoder decodeObjectForKey:@"albumArtist"];
    _URL = [aDecoder decodeObjectForKey:@"albumURL"];
    _artworkURL = [aDecoder decodeObjectForKey:@"albumArtworkURL"];
    _releaseDate = [aDecoder decodeObjectForKey:@"releaseDate"];
    _isPreOrder = [aDecoder decodeBoolForKey:@"isPreOrder"];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.title forKey:@"albumTitle"];
  [aCoder encodeObject:self.artist forKey:@"albumArtist"];
  [aCoder encodeObject:self.URL forKey:@"albumURL"];
  [aCoder encodeObject:self.artworkURL forKey:@"albumArtworkURL"];
  [aCoder encodeObject:self.releaseDate forKey:@"releaseDate"];
  [aCoder encodeBool:self.isPreOrder forKey:@"isPreOrder"];
}

- (void)addArtistId:(NSString*)artistID {
  self.artistID = [NSNumber numberWithLong:artistID.intValue];
}

- (NSComparisonResult)compare:(Album *)otherAlbum {
  return [self.releaseDate compare:otherAlbum.releaseDate];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Title:%@\nArtist:%@\nArtworkURL:%@\nAlbumURL:%@\nReleaseDate:%@\nPre-Order?: %d\n", self.title, self.artist,  self.artworkURL, self.URL, self.releaseDate, self.isPreOrder];
}

@end
