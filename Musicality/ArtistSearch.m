//
//  ArtistSearch.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "ArtistSearch.h"
#import "Blacklist.h"

@implementation ArtistSearch

- (instancetype)initWithArtist:(Artist *)artist delegate:(id<ArtistSearchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _artist = artist;
    self.queuePriority = NSOperationQueuePriorityHigh;
  }
  return self;
}

- (void)main {
  
  @autoreleasepool {
        
    NSString *formattedArtistName = [[self.artist.name stringByReplacingOccurrencesOfString:@" " withString:@"+"] lowercaseString];
    NSString *requestString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=musicArtist&limit=1", formattedArtistName];
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *artistData = [[NSData alloc] initWithContentsOfURL:requestURL];
    
    if (self.isCancelled) {
      artistData = nil;
    }
    
    if (artistData) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:artistData options:NSJSONReadingMutableContainers error:&error];
      
      NSDictionary *artistDictionary = [jsonObject[@"results"] firstObject];
      if (artistDictionary[@"artistId"] && artistDictionary[@"artistName"]) {
        [self.artist addArtistId: artistDictionary[@"artistId"]];
      }
      
      artistData = nil;

    }
    
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(artistSearchDidFinish:) withObject:self waitUntilDone:NO];
  }
}

@end
