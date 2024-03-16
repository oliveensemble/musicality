//
//  LatestReleaseSearch.m
//  Musicality
//
//  Created by Elle Lewis on 5/26/15.
//  Copyright (c) 2015 Later Creative LLC. All rights reserved.
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
    self.qualityOfService = NSOperationQualityOfServiceUserInitiated;
    self.queuePriority = NSOperationQueuePriorityNormal;
  }
  return self;
}

- (void)main {
  
  @autoreleasepool {

    NSString *requestString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=album&limit=1&order=recent", self.artist.artistID];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSData *albumData = [[NSData alloc] initWithContentsOfURL:requestURL];
    
    if (albumData) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:albumData options:NSJSONReadingMutableContainers error:&error];
      NSArray *jsonArray = jsonObject[@"results"];
      if (jsonArray.count > 1) {
        NSDictionary *albumDictionary = [jsonObject[@"results"] objectAtIndex:1];
        
        if (albumDictionary[@"collectionCensoredName"] && albumDictionary[@"collectionViewUrl"]) {
          self.privateAlbum = [[Album alloc] initWithAlbumTitle:albumDictionary[@"collectionCensoredName"] artist:self.artist.name artworkURL:albumDictionary[@"artworkUrl100"]albumURL:albumDictionary[@"collectionViewUrl"] releaseDate: albumDictionary[@"releaseDate"]];
        }
        _album = self.privateAlbum;
      }
    }
    
    albumData = nil;
    
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(latestReleaseSearchDidFinish:) withObject:self waitUntilDone:YES];
  }
}

@end
