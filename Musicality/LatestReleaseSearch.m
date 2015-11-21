//
//  LatestReleaseSearch.m
//  Musicality
//
//  Created by Evan Lewis on 5/26/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "MStore.h"
#import "LatestReleaseSearch.h"

@interface LatestReleaseSearch ()

@property (nonatomic, strong) Album *privateAlbum;

@end

@implementation LatestReleaseSearch

- (instancetype)initWithArtist:(Artist *)artist delegate:(id<LatestReleaseSearchDelegate>)delegate {
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
    
    NSString *requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=album&limit=2&sort=recent", self.artist.artistID];
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
      
      if (albumDictionary[@"collectionCensoredName"] && albumDictionary[@"collectionViewUrl"]) {
        self.privateAlbum = [[Album alloc] initWithAlbumTitle:albumDictionary[@"collectionCensoredName"] artist:self.artist.name artworkURL:albumDictionary[@"artworkUrl100"]albumURL:albumDictionary[@"collectionViewUrl"] releaseDate: albumDictionary[@"releaseDate"]];
        DLog(@"Found album: %@", self.privateAlbum.title);
      }
      _album = self.privateAlbum;
    }
    
    albumData = nil;
    
    if (self.isCancelled) {
      return;
    }
    
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(latestReleaseSearchDidFinish:) withObject:self waitUntilDone:NO];
  }
}

@end
