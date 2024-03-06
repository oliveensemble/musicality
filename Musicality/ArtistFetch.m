//
//  ArtistFetch.m
//  Musicality
//
//  Created by Elle Lewis on 1/11/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//
// Responsible for

#import "ArtistFetch.h"
#import "MStore.h"

@interface ArtistFetch ()

@property (nonatomic, strong) Artist *artist;

@end

@implementation ArtistFetch

- (instancetype)initWithDelegate:(id<ArtistFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    self.queuePriority = NSOperationQueuePriorityHigh;
  }
  return self;
}

- (void)fetchAlbumsForArtist:(Artist *)artist {
  _artist = artist;
  [self start];
}

- (void)main {
  
  @autoreleasepool {
    NSString *requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=album&order=recent", self.artist.artistID];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSData *albumData = [[NSData alloc] initWithContentsOfURL:requestURL];
    NSMutableArray *albumArray = [NSMutableArray array];
    
    if (albumData) {
      
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:albumData options:NSJSONReadingMutableContainers error:&error];
      NSArray *jsonArray = jsonObject[@"results"];
      
      for (int i = 1; i < [jsonArray count]; i++) {
        NSDictionary *albumDictionary = [jsonArray objectAtIndex:i];
        NSString *name;
        NSString *buyURL;
        NSString *artworkURL;
        NSString *releaseDate;
        NSNumber *trackCount;
        for (int j = 0; j < [albumDictionary count]; j++) {
          NSString *nodeTitle = [albumDictionary allKeys][j];
          id nodeValue = [albumDictionary allValues][j];
          
          if ([nodeTitle isEqualToString:@"collectionCensoredName"]) {
            name = nodeValue;
          } else if ([nodeTitle isEqualToString:@"collectionViewUrl"]) {
            buyURL = nodeValue;
          } else if ([nodeTitle isEqualToString:@"artworkUrl100"]) {
            artworkURL = nodeValue;
          } else if ([nodeTitle isEqualToString:@"releaseDate"]) {
            releaseDate = nodeValue;
          } else if ([nodeTitle isEqualToString:@"trackCount"]) {
            trackCount = [NSNumber numberWithInt:[nodeValue intValue]];
          }
        }
        
        Album *newAlbum = [[Album alloc] initWithAlbumTitle:name
                                                     artist:self.artist.name
                                                 artworkURL:artworkURL
                                                   albumURL:buyURL
                                                releaseDate:releaseDate];
        newAlbum.trackCount = trackCount;
        [albumArray addObject:newAlbum];
        
        name = nil;
        buyURL = nil;
        artworkURL = nil;
        releaseDate = nil;
      }
    }
    
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishFetchingArtistAlbums:) withObject: [albumArray copy] waitUntilDone:NO];
  }
}

@end
