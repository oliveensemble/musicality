//
//  NotificationCheck.m
//  Musicality
//
//  Created by Evan Lewis on 5/29/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "NotificationCheck.h"
#import "MStore.h"
#import "Album.h"

@implementation NotificationCheck

- (instancetype)initWithArtist:(Artist *)artist delegate:(id<NotificationCheckDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _artist = artist;
  }
  return self;
}

- (void)main {
  
  @autoreleasepool {
    
    if (self.isCancelled) {
      return;
    }
    
    NSString *requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=album&limit=1&sort=recent", self.artist.artistID];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *albumData = [[NSData alloc] initWithContentsOfURL:requestURL];
    
    if (self.isCancelled) {
      albumData = nil;
      return;
    }
    
    if (albumData) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:albumData options:NSJSONReadingMutableContainers error:&error];
      
      NSDictionary *albumDictionary = [jsonObject[@"results"] lastObject];
      NSDate *latestReleaseDate = [mStore formattedDateFromString:albumDictionary[@"releaseDate"]];
      if ([mStore thisDate:latestReleaseDate isMoreRecentThan:self.artist.latestRelease.releaseDate]) {
        self.artistNeedsUpdating = YES;
        self.artist.latestRelease = [[Album alloc] initWithAlbumTitle:albumDictionary[@"collectionCensoredName"]
                                                               artist:self.artist.name
                                                           artworkURL:albumDictionary[@"artworkUrl100"]
                                                             albumURL:albumDictionary[@"collectionViewUrl"]
                                                          releaseDate:albumDictionary[@"releaseDate"]];
      } else {
        self.artistNeedsUpdating = NO;
      }
    }
    
    albumData = nil;
    
    if (self.isCancelled) {
      return;
    }
    
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(notificationCheckDidFinish:) withObject:self waitUntilDone:NO];
  }
}

@end
