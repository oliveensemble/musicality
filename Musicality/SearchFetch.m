//
//  SearchFetch.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchFetch.h"
#import "Album.h"
#import "Artist.h"

typedef NS_OPTIONS(NSUInteger, SearchType) {
  artists = 1 << 0,
  albums = 1 << 1
};

@interface SearchFetch ()

@property (nonatomic) NSUInteger searchType;
@property (copy, nonatomic) NSString *searchTerm;
@property (nonatomic) NSMutableArray *searchResultsArray;

@end

@implementation SearchFetch

- (instancetype)initWithSearchType:(NSUInteger)searchType searchTerm:(NSString *)searchTerm delegate:(id<SearchFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _searchType = searchType;
    _searchTerm = searchTerm;
    self.queuePriority = NSOperationQueuePriorityVeryHigh;
  }
  return self;
}

- (void)main {
  
  @autoreleasepool {
    
    if (self.isCancelled) {
      return;
    }
    
    NSString *requestString;
    self.searchTerm = [self.searchTerm lowercaseString];
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    if (self.searchType == albums) {
      requestString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=album&attribute=albumTerm&limit=25", self.searchTerm];
    } else {
      requestString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=musicArtist&limit=25", self.searchTerm];
    }
    
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *searchData = [[NSData alloc] initWithContentsOfURL:requestURL];
    
    if (self.isCancelled) {
      searchData = nil;
      return;
    }
    
    if (searchData) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONReadingMutableContainers error:&error];
      NSArray *jsonArray = jsonObject[@"results"];
      _searchResultsArray = [NSMutableArray arrayWithCapacity:25];
      
      if (jsonArray.count > 1) {
        if (self.searchType == albums) {
          // Iterate through the albums in the json file
          for (NSDictionary *albumDictionary in jsonArray) {
            if (albumDictionary[@"collectionCensoredName"] && albumDictionary[@"collectionViewUrl"]) {
              Album *albumResult = [[Album alloc] initWithAlbumTitle: albumDictionary[@"collectionCensoredName"] artist: albumDictionary[@"artistName"] artworkURL:albumDictionary[@"artworkUrl100"]albumURL:albumDictionary[@"collectionViewUrl"] releaseDate: albumDictionary[@"releaseDate"]];
              [self.searchResultsArray addObject: albumResult];
            }
          }
        } else if (self.searchType == artists) {
          // Iterate through the artists in the json file
          for (NSDictionary *artistDictionary in jsonArray) {
            if (artistDictionary[@"artistName"] && artistDictionary[@"artistId"]) {
              Artist *artistResult = [[Artist alloc] initWithArtistID:artistDictionary[@"artistId"] andName:artistDictionary[@"artistName"]];
              [self.searchResultsArray addObject: artistResult];
            }
          }
        }
      }
      
      searchData = nil;
      
      if (self.isCancelled) {
        return;
      }
      
      //Cast the operation to NSObject, and notify the caller on the main thread.
      [(NSObject *)self.delegate performSelectorOnMainThread:@selector(searchFetchDidFinish:) withObject:self waitUntilDone:NO];
    }
    
  }
  
}

@end
