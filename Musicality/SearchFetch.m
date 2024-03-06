//
//  SearchFetch.m
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

#import "SearchFetch.h"
#import "Album.h"
#import "Artist.h"
#import "MStore.h"

typedef NS_OPTIONS(NSUInteger, SearchType) {
  artists = 1 << 0,
  albums = 1 << 1
};

@interface SearchFetch ()

@property (nonatomic) NSUInteger searchType;
@property (copy, nonatomic) NSString *searchTerm;

@end

@implementation SearchFetch

- (instancetype)initWithDelegate:(id<SearchFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    self.queuePriority = NSOperationQueuePriorityVeryHigh;
  }
  return self;
}

- (void)fetchItemsForSearchTerm:(NSString *)searchTerm withType:(NSUInteger)searchType {
  _searchTerm = searchTerm;
  _searchType = searchType;
  [self start];
}

- (void)main {
  
  @autoreleasepool {

    NSString *requestString;
    self.searchTerm = [self.searchTerm lowercaseString];
    self.searchTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    if (self.searchType == albums) {
      requestString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=album&attribute=albumTerm&limit=50", self.searchTerm];
    } else {
      requestString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=musicArtist&limit=50", self.searchTerm];
    }
    
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSData *searchData = [[NSData alloc] initWithContentsOfURL:requestURL];
    
    DLog(@"Searching: %@", requestURL.absoluteString);
    
    if (self.isCancelled) {
      searchData = nil;
    }
    
    if (searchData) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONReadingMutableContainers error:&error];
      NSArray *jsonArray = jsonObject[@"results"];
      NSMutableArray *searchResultsArray = [NSMutableArray arrayWithCapacity:50];
      
      if (jsonArray.count > 0) {
        if (self.searchType == albums) {
          // Iterate through the albums in the json file
          for (NSDictionary *albumDictionary in jsonArray) {
            if (albumDictionary[@"collectionCensoredName"] && albumDictionary[@"collectionViewUrl"]) {
              Album *albumResult = [[Album alloc] initWithAlbumTitle: albumDictionary[@"collectionCensoredName"]
                                                              artist: albumDictionary[@"artistName"]
                                                          artworkURL: albumDictionary[@"artworkUrl100"]
                                                            albumURL: albumDictionary[@"collectionViewUrl"]
                                                         releaseDate: albumDictionary[@"releaseDate"]];
              
              if (![albumResult.artist isEqualToString:@"Various Artists"]) {
                [albumResult addArtistId: albumDictionary[@"artistId"]];
              }
              
              [searchResultsArray addObject: albumResult];
            }
          }
        } else if (self.searchType == artists) {
          // Iterate through the artists in the json file
          for (NSDictionary *artistDictionary in jsonArray) {
            if (artistDictionary[@"artistName"] && artistDictionary[@"artistId"]) {
              Artist *artistResult = [[Artist alloc] initWithArtistID:artistDictionary[@"artistId"] andName:artistDictionary[@"artistName"]];
              [searchResultsArray addObject: artistResult];
            }
          }
        }
      }
      
      searchData = nil;
      
      //Cast the operation to NSObject, and notify the caller on the main thread.
      [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishSearchWithResults:) withObject:[searchResultsArray copy] waitUntilDone:NO];
    } else {
        DLog(@"Uh oh....");
    }
  }
}

@end
